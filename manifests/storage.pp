# This class configures the Bareos storage daemon.
#
# @param bin
# @param conf_dir
# @param device
# @param device_mode
# @param device_password
# @param device_seltype
# @param director_name
# @param group
# @param homedir
# @param include_repo
# @param install
# @param listen_address INET or INET6 address to listen on
# @param maxconcurjobs
# @param media_type
# @param packages
# @param port The listening port for the Storage Daemon
# @param rundir
# @param rundir
# @param services
# @param storage
# @param user
# @param validate_config
#
class bareos::storage (
  String $service,
  Array[String, 1] $packages,
  Stdlib::Absolutepath $bin,
  Stdlib::Absolutepath $conf_dir   = $bareos::conf_dir,
  String $device                   = '/bareos',
  String $device_mode              = '0770',
  String $device_name              = "${trusted['certname']}-device",
  String $device_owner             = $bareos::bareos_user,
  Optional[String] $device_seltype = $bareos::device_seltype,
  String $director_name            = $bareos::director_name,
  String $group                    = $bareos::bareos_group,
  Stdlib::Absolutepath $homedir    = $bareos::homedir,
  String $listen_address           = $facts['ipaddress'],
  Integer[1] $maxconcurjobs        = 5,
  String $media_type               = 'File',
  String $password                 = 'secret',
  Integer[1] $port                 = 9103,
  Stdlib::Absolutepath $rundir     = $bareos::rundir,
  String $storage                  = $trusted['certname'], # storage here is not storage_name
  String $address                  = $facts['fqdn'],
  String $user                     = $bareos::bareos_user,
  Boolean $validate_config         = true,
  Boolean $include_repo            = true,
  Boolean $install                 = true,
) inherits ::bareos {

  if $include_repo {
    include '::bareos::repo'
  }

  if $install {
    # Packages are virtual due to some platforms shipping the
    # SD and Dir as part of the same package.
    include ::bareos::virtual

    # Allow for package names to include EPP syntax for db_type
    $db_type = lookup('bareos::director::db_type')
    $package_names = $packages.map |$p| {
      $package_name = inline_epp($p, {
        'db_type' => $db_type
      })
    }

    realize(Package[$package_names])

    Package[$package_names] -> Service['bareos-sd']
    Package[$package_names] -> Concat["${conf_dir}/bareos-sd.conf"]
  }

  service { 'bareos-sd':
    ensure  => running,
    name    => $service,
    enable  => true,
  }

  if $::bareos::use_ssl == true {
    include ::bareos::ssl
    File[$::bareos::ssl::ssl_files] ~> Service['bareos-sd']
  }

  concat::fragment { 'bareos-storage-header':
    order   => '00',
    target  => "${conf_dir}/bareos-sd.conf",
    content => template('bareos/bareos-sd-header.erb'),
  }

  bareos::storage::device { $device_name:
    device => $device,
  }

  concat::fragment { 'bareos-storage-dir':
    target  => "${conf_dir}/bareos-sd.conf",
    content => template('bareos/bareos-sd-dir.erb'),
  }

  bareos::messages { 'Standard-sd':
    daemon   => 'sd',
    director => "${director_name}-dir = all",
    syslog   => 'all, !skipped',
    append   => '"/var/log/bareos/bareos-sd.log" = all, !skipped',
  }

  # Realize the clause the director is exporting here so we can allow access to
  # the storage daemon Adds an entry to ${conf_dir}/bareos-sd.conf
  Concat::Fragment <<| tag == "bareos-storage-dir-${director_name}" |>>

  $validate_cmd = $validate_config ? {
    false   => undef,
    default => shell_join([$bin, '-t', '-c', '%']),
  }

  concat { "${conf_dir}/bareos-sd.conf":
    owner        => 'root',
    group        => $group,
    mode         => '0640',
    show_diff    => false,
    notify       => Service['bareos-sd'],
    validate_cmd => $validate_cmd,
  }

  @@bareos::director::storage { $storage:
    address       => $address,
    port          => $port,
    password      => $password,
    device_name   => $device_name,
    media_type    => $media_type,
    maxconcurjobs => $maxconcurjobs,
    tag           => "bareos-${director_name}",
  }
}

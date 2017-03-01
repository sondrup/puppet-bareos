# Class: bareos::storage
#
# Configures bareos storage daemon
#
class bareos::storage (
  Integer[1] $port                 = 9103,
  String $listen_address           = $::ipaddress,
  String $storage                  = $::fqdn, # storage here is not params::storage
  String $password                 = 'secret',
  String $device_name              = "${::fqdn}-device",
  String $device                   = '/bareos',
  String $device_mode              = '0770',
  String $device_owner             = $bareos::params::bareos_user,
  Optional[String] $device_seltype = $bareos::params::device_seltype,
  String $media_type               = 'File',
  Integer[1] $maxconcurjobs        = 5,
  Array[String, 1] $packages       = $bareos::params::bareos_storage_packages,
  String $service                  = $bareos::params::bareos_storage_service,
  Stdlib::Absolutepath $homedir    = $bareos::params::homedir,
  Stdlib::Absolutepath $rundir     = $bareos::params::rundir,
  Stdlib::Absolutepath $conf_dir   = $bareos::params::conf_dir,
  String $director                 = $bareos::params::director,
  String $user                     = $bareos::params::bareos_user,
  String $group                    = $bareos::params::bareos_group,
  Stdlib::Absolutepath $bin        = $bareos::params::bareos_storage_bin,
  Boolean $validate_config         = true,
  Boolean $include_repo            = true,
  Boolean $install                 = true,
) inherits bareos::params {

  include bareos::common
  include bareos::ssl
  include bareos::virtual

  if $include_repo {
    include '::bareos::repo'
  }

  if $install {
    realize(Package[$packages])
  }

  service { 'bareos-sd':
    name      => $service,
    ensure    => running,
    enable    => true,
    subscribe => File[$bareos::ssl::ssl_files],
    require   => Package[$packages],
  }

  concat::fragment { 'bareos-storage-header':
    order   => '00',
    target  => "${conf_dir}/bareos-sd.conf",
    content => template('bareos/bareos-sd-header.erb'),
  }

  concat::fragment { 'bareos-storage-dir':
    target  => "${conf_dir}/bareos-sd.conf",
    content => template('bareos/bareos-sd-dir.erb'),
  }

  bareos::messages { 'Standard-sd':
    daemon   => 'sd',
    director => "${director}-dir = all",
    syslog   => 'all, !skipped',
    append   => '"/var/log/bareos/bareos-sd.log" = all, !skipped',
  }

  # Realize the clause the director is exporting here so we can allow access to
  # the storage daemon Adds an entry to ${conf_dir}/bareos-sd.conf
  Concat::Fragment <<| tag == "bareos-storage-dir-${director}" |>>

  $validate_cmd = $validate_config ? {
    false   => undef,
    default => shell_join([$bin, '-t', '-c', '%']),
  }

  concat { "${conf_dir}/bareos-sd.conf":
    owner        => 'root',
    group        => $group,
    mode         => '0640',
    show_diff    => false,
    require      => Package[$packages],
    notify       => Service['bareos-sd'],
    validate_cmd => $validate_cmd,
  }

  if $media_type == 'File' {
    file { $device:
      ensure  => directory,
      owner   => $device_owner,
      group   => $group,
      mode    => $device_mode,
      seltype => $device_seltype,
      require => Package[$packages],
    }
  }

  @@bareos::director::storage { $storage:
    port          => $port,
    password      => $password,
    device_name   => $device_name,
    media_type    => $media_type,
    maxconcurjobs => $maxconcurjobs,
    tag           => "bareos-${::bareos::params::storage}",
  }
}

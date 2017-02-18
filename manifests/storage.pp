# Class: bareos::storage
#
# Configures bareos storage daemon
#
class bareos::storage (
  $port                    = '9103',
  $listen_address          = $::ipaddress,
  $storage                 = $::fqdn, # storage here is not params::storage
  $password                = 'secret',
  $device_name             = "${::fqdn}-device",
  $device                  = '/bareos',
  $device_mode             = '0770',
  $device_owner            = $bareos::params::bareos_user,
  $device_seltype          = $bareos::params::device_seltype,
  $media_type              = 'File',
  $maxconcurjobs           = '5',
  $packages                = $bareos::params::bareos_storage_packages,
  $service                 = $bareos::params::bareos_storage_service,
  $homedir                 = $bareos::params::homedir,
  $rundir                  = $bareos::params::rundir,
  $conf_dir                = $bareos::params::conf_dir,
  $director                = $bareos::params::director,
  $user                    = $bareos::params::bareos_user,
  $group                   = $bareos::params::bareos_group,
  $include_repo            = true,
  $install                 = true,
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
    order   => 00,
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

  concat { "${conf_dir}/bareos-sd.conf":
    owner     => 'root',
    group     => $group,
    mode      => '0640',
    show_diff => false,
    notify    => Service['bareos-sd'],
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

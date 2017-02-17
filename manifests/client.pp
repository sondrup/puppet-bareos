# Class: bareos::client
#
# This class installs and configures the File Daemon to backup a client system.
#
# Sample Usage:
#
#   class { 'bareos::client': director => 'mydirector.example.com' }
#
class bareos::client (
  $port                = '9102',
  $listen_address      = $::ipaddress,
  $password            = 'secret',
  $max_concurrent_jobs = '2',
  $packages            = $bareos::params::bareos_client_packages,
  $services            = $bareos::params::bareos_client_services,
  $conf_dir            = $bareos::params::conf_dir,
  $director            = $bareos::params::director,
  $storage             = $bareos::params::storage,
  $group               = $bareos::params::bareos_group,
  $client_config       = $bareos::params::client_config,
  $autoprune           = $bareos::params::autoprune,
  $file_retention      = $bareos::params::file_retention,
  $job_retention       = $bareos::params::job_retention,
  $client              = $::fqdn,
  $default_pool        = 'Default',
  $default_pool_full   = undef,
  $default_pool_inc    = undef,
  $default_pool_diff   = undef,
) inherits bareos::params {

  include bareos::common
  include bareos::ssl

  package { $packages:
    ensure => present,
  }

  service { $services:
    ensure    => running,
    enable    => true,
    subscribe => File[$bareos::ssl::ssl_files],
    require   => Package[$packages],
  }

  concat { $client_config:
    owner     => 'root',
    group     => $group,
    mode      => '0640',
    show_diff => false,
    require   => Package[$bareos::params::bareos_client_packages],
    notify    => Service[$bareos::params::bareos_client_services],
  }

  concat::fragment { 'bareos-client-header':
    target  => $client_config,
    content => template('bareos/bareos-fd-header.erb'),
  }

  bareos::messages { 'Standard-fd':
    daemon   => 'fd',
    director => "${director}-dir = all, !skipped, !restored",
    append   => '"/var/log/bareos/bareos-fd.log" = all, !skipped',
  }

  # Tell the director about this client config
  @@bareos::director::client { $client:
    port           => $port,
    client         => $client,
    password       => $password,
    autoprune      => $autoprune,
    file_retention => $file_retention,
    job_retention  => $job_retention,
    tag            => "bareos-${::bareos::params::director}",
  }
}

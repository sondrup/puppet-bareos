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
  $package             = $bareos::params::bareos_client_package,
  $service             = $bareos::params::bareos_client_service,
  $conf_dir            = $bareos::params::conf_dir,
  $director            = $bareos::params::director,
  $storage             = $bareos::params::storage,
  $group               = $bareos::params::bareos_group,
  $client_config       = $bareos::params::client_config,
  $autoprune           = $bareos::params::autoprune,
  $file_retention      = $bareos::params::file_retention,
  $job_retention       = $bareos::params::job_retention,
  $bin                 = $bareos::params::bareos_client_bin,
  $validate_config     = true,
  $client              = $::fqdn,
  $default_pool        = 'Default',
  $default_pool_full   = undef,
  $default_pool_inc    = undef,
  $default_pool_diff   = undef,
  $include_repo        = true,
  $install             = true,
) inherits bareos::params {

  include bareos::common
  include bareos::ssl

  if $include_repo {
    include '::bareos::repo'
  }

  if $install {
    package { 'bareos-client':
      name   => $package,
      ensure => present,
      tag    => 'bareos',
    }
  }

  service { 'bareos-client':
    name      => $service,
    ensure    => running,
    enable    => true,
    subscribe => File[$bareos::ssl::ssl_files],
    require   => Package[$package],
  }

  $validate_cmd = $validate_config ? {
    false   => undef,
    default => shell_join([$bin, '-t', '-c', '%']),
  }

  concat { $client_config:
    owner        => 'root',
    group        => $group,
    mode         => '0640',
    show_diff    => false,
    require      => Package['bareos-client'],
    notify       => Service['bareos-client'],
    validate_cmd => $validate_cmd,
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

# Class: bareos::client
#
# This class installs and configures the File Daemon to backup a client system.
#
# Sample Usage:
#
#   class { 'bareos::client': director => 'mydirector.example.com' }
#
class bareos::client (
  Integer[1] $port                    = 9102,
  String $listen_address              = $::ipaddress,
  String $password                    = 'secret',
  Integer[1] $max_concurrent_jobs     = 2,
  String $package                     = $bareos::params::bareos_client_package,
  String $service                     = $bareos::params::bareos_client_service,
  Stdlib::Absolutepath $conf_dir      = $bareos::params::conf_dir,
  String $director                    = $bareos::params::director,
  String $storage                     = $bareos::params::storage,
  String $group                       = $bareos::params::bareos_group,
  Stdlib::Absolutepath $client_config = $bareos::params::client_config,
  Bareos::Yesno $autoprune            = $bareos::params::autoprune,
  Bareos::Time $file_retention        = $bareos::params::file_retention,
  Bareos::Time $job_retention         = $bareos::params::job_retention,
  Stdlib::Absolutepath $bin           = $bareos::params::bareos_client_bin,
  Boolean $validate_config            = true,
  String $client                      = $::fqdn,
  String $default_pool                = 'Default',
  Boolean $default_pool_full          = false,
  Boolean $default_pool_inc           = false,
  Boolean $default_pool_diff          = false,
  Boolean $include_repo               = true,
  Boolean $install                    = true,
) inherits bareos::params {

  include ::bareos::common
  include ::bareos::ssl

  if $include_repo {
    include '::bareos::repo'
  }

  if $install {
    package { 'bareos-client':
      ensure => present,
      name   => $package,
      tag    => 'bareos',
    }
  }

  service { 'bareos-client':
    ensure    => running,
    name      => $service,
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

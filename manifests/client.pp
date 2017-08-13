# This class installs and configures the File Daemon to backup a client system.
#
# @param port The listening port for the File Daemon
# @param listen_address The listening INET or INET6 address for File Daemon
# @param password A password to use for communication with this File Daemon
# @param max_concurrent_jobs Bareos FD option for 'Maximum Concurrent Jobs'
# @param package A list of packages to install; loaded from hiera
# @param service A list of services to operate; loaded from hiera
# @param bin Path to bareos fd binary; loaded from hiera
# @param director_name The hostname of the director for this FD
# @param autoprune Bareos FD option for 'AutoPrune'
# @param file_retention Bareos FD option for 'File Retention'
# @param job_retention Bareos FD option for 'Job Retention'
# @param client The name or address by which to contact this FD
# @param default_pool The name of the Pool for this FD to use by default
# @param default_pool_full The name of the Pool to use for Full jobs
# @param default_pool_inc The name of the Pool to use for Incremental jobs
# @param default_pool_diff The name of the Pool to use for Differential jobs
#
# @example
#   class { 'bareos::client': director_name => 'mydirector.example.com' }
#
class bareos::client (
  String $package,
  String $service,
  Stdlib::Absolutepath $bin,
  String $default_pool,
  Optional[String] $default_pool_full,
  Optional[String] $default_pool_inc,
  Optional[String] $default_pool_diff,
  Integer[1] $port                = 9102,
  String $listen_address          = $facts['ipaddress'],
  String $password                = 'secret',
  Integer[1] $max_concurrent_jobs = 2,
  String $director_name           = $bareos::director_name,
  Bareos::Yesno $autoprune        = 'yes',
  Bareos::Time $file_retention    = '45 days',
  Bareos::Time $job_retention     = '6 months',
  String $client                  = $trusted['certname'],
  String $address                 = $facts['fqdn'],
  Boolean $validate_config        = true,
  Boolean $include_repo           = true,
  Boolean $install                = true,
) inherits bareos {

  $group    = $::bareos::bareos_group
  $conf_dir = $::bareos::conf_dir
  $config_file = "${conf_dir}/bareos-fd.conf"

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
    ensure  => running,
    name    => $service,
    enable  => true,
    require => Package[$package],
  }

  $validate_cmd = $validate_config ? {
    false   => undef,
    default => shell_join([$bin, '-t', '-c', '%']),
  }

  if $::bareos::use_ssl == true{
    include ::bareos::ssl
    File[$::bareos::ssl::ssl_files] ~> Service[$service]
  }

  concat { $config_file:
    owner        => 'root',
    group        => $group,
    mode         => '0640',
    show_diff    => false,
    require      => Package['bareos-client'],
    notify       => Service['bareos-client'],
    validate_cmd => $validate_cmd,
  }

  concat::fragment { 'bareos-client-header':
    target  => $config_file,
    content => template('bareos/bareos-fd-header.erb'),
  }

  bareos::messages { 'Standard-fd':
    daemon   => 'fd',
    director => "${director_name}-dir = all, !skipped, !restored",
    append   => '"/var/log/bareos/bareos-fd.log" = all, !skipped',
  }

  # Tell the director about this client config
  @@bareos::director::client { $client:
    address        => $address,
    port           => $port,
    password       => $password,
    autoprune      => $autoprune,
    file_retention => $file_retention,
    job_retention  => $job_retention,
    tag            => "bareos-${director_name}",
  }
}

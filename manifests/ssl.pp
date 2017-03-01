# Class: bareos::ssl
#
# Manage the SSL deployment for bareos components, Director, Storage, and File.
class bareos::ssl (
  Stdlib::Absolutepath $ssl_dir  = $bareos::params::ssl_dir,
  Stdlib::Absolutepath $conf_dir = $bareos::params::conf_dir,
  Stdlib::Absolutepath $certfile = $bareos::params::certfile,
  Stdlib::Absolutepath $keyfile  = $bareos::params::keyfile,
  Stdlib::Absolutepath $cafile   = $bareos::params::cafile,
  String $package                = $bareos::params::bareos_client_package,
  String $user                   = $bareos::params::bareos_user,
  String $conf_user              = $bareos::params::bareos_user,
  String $conf_group             = $bareos::params::bareos_group,
) inherits bareos::params {

  $ssl_files = [
    $certfile,
    $keyfile,
    $cafile,
  ]

  $bareos_ssl_dir = "${conf_dir}/ssl"

  file {
    default:
      owner   => $user,
      group   => '0',
      mode    => '0640',
      require => Package[$package],;

    $conf_dir:
      ensure => 'directory',
      owner  => $conf_user,
      group  => $conf_group,
      before => File[$bareos_ssl_dir],;

    $bareos_ssl_dir:
      ensure  => 'directory',
      require => File[$conf_dir],
      before  => File[$ssl_files],;

    $certfile:
      source  => "${ssl_dir}/certs/${::clientcert}.pem",
      require => File[$bareos_ssl_dir],;

    $keyfile:
      source  => "${ssl_dir}/private_keys/${::clientcert}.pem",
      require => File[$bareos_ssl_dir],;

    $cafile:
      ensure  => 'file',
      source  => "${ssl_dir}/certs/ca.pem",
      require => File[$bareos_ssl_dir],;
  }

  exec { 'generate_bareos_dhkey':
    command => 'openssl dhparam -out dh1024.pem -5 1024',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
    cwd     => $bareos_ssl_dir,
    creates => "${bareos_ssl_dir}/dh1024.pem",
    require => File[$bareos_ssl_dir],
  }
}

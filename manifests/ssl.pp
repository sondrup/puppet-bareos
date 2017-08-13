# Manage the SSL deployment for bareos components, Director, Storage, and File
# daemons.
#
# @param packages
#
# @example
#   include bareos::ssl
#
# @example in hiera
#   TODO
#
# TODO make DH key length configurable
#
class bareos::ssl (
  String $ssl_dir,
) {

  include ::bareos
  include ::bareos::client

  $conf_dir     = $::bareos::conf_dir
  $bareos_user = $::bareos::bareos_user

  $certfile = "${conf_dir}/ssl/${trusted['certname']}_cert.pem"
  $keyfile  = "${conf_dir}/ssl/${trusted['certname']}_key.pem"
  $cafile   = "${conf_dir}/ssl/ca.pem"

  $ssl_files = [
    $certfile,
    $keyfile,
    $cafile,
  ]

  $bareos_ssl_dir = "${conf_dir}/ssl"

  file {
    default:
      owner   => $bareos_user,
      group   => '0',
      mode    => '0640',
      require => Package[$bareos::client::package],;

    $bareos_ssl_dir:
      ensure  => 'directory',
      require => File[$conf_dir],
      before  => File[$ssl_files],;

    $certfile:
      source  => "${ssl_dir}/certs/${trusted['certname']}.pem",
      require => File[$bareos_ssl_dir],;

    $keyfile:
      source  => "${ssl_dir}/private_keys/${trusted['certname']}.pem",
      require => File[$bareos_ssl_dir],;

    $cafile:
      ensure  => 'file',
      source  => "${ssl_dir}/certs/ca.pem",
      require => File[$bareos_ssl_dir],;
  }

  exec { 'generate_bareos_dhkey':
    command => 'openssl dhparam -out dh2048.pem -5 2048',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
    cwd     => $bareos_ssl_dir,
    creates => "${bareos_ssl_dir}/dh2048.pem",
    timeout => 0,
    require => File[$bareos_ssl_dir],
  }
}

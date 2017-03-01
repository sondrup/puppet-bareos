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
    $cafile
  ]

  File {
    owner   => $user,
    group   => '0',
    mode    => '0640',
    require => Package[$package],
  }

  file { $conf_dir:
    ensure => 'directory',
    owner  => $conf_user,
    group  => $conf_group,
  } ->

  file { "${conf_dir}/ssl":
    ensure => 'directory',
  }

  file { $certfile:
    source  => "${ssl_dir}/certs/${::clientcert}.pem",
    require => File["${conf_dir}/ssl"],
  }

  file { $keyfile:
    source  => "${ssl_dir}/private_keys/${::clientcert}.pem",
    require => File["${conf_dir}/ssl"],
  }

  # Now export our key and cert files so the director can collect them,
  # while we've still realized the actual files, except when we're on
  # the director already.
  #unless ($::fqdn == $bareos::params::director_name) {
  #  @@bareos::ssl::certfile { $::clientcert: }
  #  @@bareos::ssl::keyfile  { $::clientcert: }
  #}

  file { $cafile:
    ensure  => 'file',
    source  => "${ssl_dir}/certs/ca.pem",
    require => File["${conf_dir}/ssl"],
  }

  exec { 'generate_bareos_dhkey':
    command => 'openssl dhparam -out dh1024.pem -5 1024',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
    cwd     => "${conf_dir}/ssl",
    creates => "${conf_dir}/ssl/dh1024.pem",
    require => File["${conf_dir}/ssl"],
  }
}

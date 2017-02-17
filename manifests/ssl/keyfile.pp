# == Define: bareos::ssl::keyfile
#
# Type to help the director install new client keys.
#
define bareos::ssl::keyfile {
  file { "keyfile-${name}":
    path    => "${bareos::params::conf_dir}/ssl/${name}_key.pem",
    owner   => $bareos::params::bareos_user,
    group   => '0',
    mode    => '0640',
    content => hiera("bareos_ssl_keyfile_${name}"),
  }
}

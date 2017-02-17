# == Define: bareos::ssl::certfile
#
# Type to help the director install new client certificates.
#
define bareos::ssl::certfile {
  file { "certfile-${name}":
    path    => "${bareos::params::conf_dir}/ssl/${name}_cert.pem",
    owner   => $bareos::params::bareos_user,
    group   => '0',
    mode    => '0640',
    content => hiera("bareos_ssl_certfile_${name}"),
  }
}

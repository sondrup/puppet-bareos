# This class configures and installs the bareos client packages and enables the
# service, so that bareos jobs can be run on the client including this
# manifest.
#
class bareos::common {
  include ::bareos
  include ::bareos::client

  $conf_dir        = $::bareos::conf_dir
  $bareos_user     = $::bareos::bareos_user
  $bareos_group    = $::bareos::bareos_group
  $homedir         = $::bareos::homedir
  $homedir_mode    = $::bareos::homedir_mode
  $client_package  = $::bareos::client::package

  File {
    ensure  => directory,
    owner   => $bareos_user,
    group   => $bareos_group,
    require => Package[$client_package],
  }

  file { $homedir:
    mode => $homedir_mode,
  }

  file { $conf_dir:
    ensure => 'directory',
    owner  => $bareos_user,
    group  => $bareos_group,
    mode   => '0750',
  }

}

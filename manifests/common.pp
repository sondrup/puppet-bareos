# = Class: bareos::common
#
# == Description
#
# This class configures and installs the bareos client packages and enables
# the service, so that bareos jobs can be run on the client including this
# manifest.
#
class bareos::common (
  Stdlib::Absolutepath $homedir = $bareos::params::homedir,
  String $homedir_mode          = '0770',
  String $package               = $bareos::params::bareos_client_package,
  String $user                  = $bareos::params::bareos_user,
  String $group                 = $bareos::params::bareos_group,
) inherits bareos::params {

  include bareos::ssl
  include bareos::client

  file { $homedir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $homedir_mode,
    require => Package[$package],
  }
}

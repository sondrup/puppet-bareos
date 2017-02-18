# = Class: bareos::common
#
# == Description
#
# This class configures and installs the bareos client packages and enables
# the service, so that bareos jobs can be run on the client including this
# manifest.
#
class bareos::common (
  $homedir      = $bareos::params::homedir,
  $homedir_mode = '0770',
  $package      = $bareos::params::bareos_client_package,
  $user         = $bareos::params::bareos_user,
  $group        = $bareos::params::bareos_group,
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

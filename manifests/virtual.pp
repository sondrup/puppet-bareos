# Class: bareos::virtual
#
# This class contains virtual resources shared between the bareos::director
# and bareos::storage classes.
#
class bareos::virtual(
  $director_packages = $bareos::params::bareos_director_packages,
  $storage_packages  = $bareos::params::bareos_storage_packages,
) inherits bareos::params {
  # Get the union of all the packages so we prevent having duplicate packages,
  # which is exactly the reason for having a virtual package resource.
  $packages = union($director_packages, $storage_packages)
  @package { $packages:
    ensure => present,
    tag    => 'bareos',
  }
}

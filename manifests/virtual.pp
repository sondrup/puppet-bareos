# Class: bareos::virtual
#
# This class contains virtual resources shared between the bareos::director and
# bareos::storage classes.  This allows the director and storate roles to be
# installed on either seperate machines, or the same machine.  On some
# platforms, the director package and storate package are the same, while on
# other platforms there are seperate packages for each.
#
class bareos::virtual {
  # Get the union of all the packages so we prevent having duplicate packages,
  # which is exactly the reason for having a virtual package resource.

  $director_packages = lookup('bareos::director::packages')
  $storage_packages  = lookup('bareos::storage::packages')
  $db_type           = lookup('bareos::director::db_type')
  $packages          = ($director_packages + $storage_packages).unique

  $packages.each |$p| {
    $package_name = inline_epp($p, {
      'db_type' => $db_type
    })

    @package { $package_name:
      ensure => present,
    }
  }
}

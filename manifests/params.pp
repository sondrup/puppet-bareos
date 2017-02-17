# Class: bareos::params
#
# Set some platform specific paramaters.
#
class bareos::params {

  $file_retention = '45 days'
  $job_retention  = '6 months'
  $autoprune      = 'yes'
  $monitor        = true
  $ssl            = hiera('bareos::params::ssl', false)
  $ssl_dir        = hiera('bareos::params::ssl_dir', '/etc/puppetlabs/puppet/ssl')
  $device_seltype = 'bareos_store_t'

  validate_bool($ssl)

  if $facts['operatingsystem'] in ['RedHat', 'CentOS', 'Fedora', 'Scientific'] {
    $db_type        = hiera('bareos::params::db_type', 'postgresql')
  } else {
    $db_type        = hiera('bareos::params::db_type', 'pgsql')
  }

  $storage          = hiera('bareos::params::storage', $::fqdn)
  $director         = hiera('bareos::params::director', $::fqdn)
  $director_address = hiera('bareos::params::director_address', $director)
  $job_tag          = hiera('bareos::params::job_tag', '')

  case $facts['operatingsystem'] {
    'Ubuntu','Debian': {
      $bareos_director_packages = [ 'bareos-director-common', "bareos-director-${db_type}", 'bareos-console' ]
      $bareos_director_services = [ 'bareos-director' ]
      $bareos_storage_packages  = [ 'bareos-sd', "bareos-sd-${db_type}" ]
      $bareos_storage_services  = [ 'bareos-sd' ]
      $bareos_client_packages   = 'bareos-client'
      $bareos_client_services   = 'bareos-fd'
      $conf_dir                 = '/etc/bareos'
      $bareos_dir               = '/etc/bareos/ssl'
      $client_config            = '/etc/bareos/bareos-fd.conf'
      $homedir                  = '/var/lib/bareos'
      $rundir                   = '/var/run/bareos'
      $bareos_user              = 'bareos'
      $bareos_group             = $bareos_user
    }
    'RedHat','CentOS','Fedora','Scientific': {
      if 0 + $facts['operatingsystemmajrelease'] < 7 or ($facts['operatingsystem'] == 'Fedora' and 0 + $facts['operatingsystemmajrelease'] < 17) {
        $bareos_director_packages = [ 'bareos-director-common', "bareos-director-${db_type}", 'bareos-console' ]
        $bareos_storage_packages  = [ 'bareos-storage-common', "bareos-storage-${db_type}" ]
      } else {
        $bareos_director_packages = [ 'bareos-director', 'bareos-console' ]
        $bareos_storage_packages  = [ 'bareos-storage' ]
      }
      $bareos_director_services = [ 'bareos-dir' ]
      $bareos_storage_services  = [ 'bareos-sd' ]
      $bareos_client_packages   = 'bareos-client'
      $bareos_client_services   = 'bareos-fd'
      $conf_dir                 = '/etc/bareos'
      $bareos_dir               = '/etc/bareos/ssl'
      $client_config            = '/etc/bareos/bareos-fd.conf'
      $homedir                  = '/var/spool/bareos'
      $rundir                   = '/var/run'
      $bareos_user              = 'bareos'
      $bareos_group             = $bareos_user
    }
    default: { fail("bareos::params has no love for ${facts['operatingsystem']}") }
  }

  $certfile = "${conf_dir}/ssl/${::clientcert}_cert.pem"
  $keyfile  = "${conf_dir}/ssl/${::clientcert}_key.pem"
  $cafile   = "${conf_dir}/ssl/ca.pem"
}

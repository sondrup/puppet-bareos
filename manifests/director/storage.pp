# Define: bareos::director::storage
#

# This define creates a storage declaration for the
# director.  This informs the director which storage
# servers are available to send client backups to.
#
# This resource is intended to be used from
# bareos::storage as an exported resource, so that
# each storage server is available as a configuration
# on the director.
#
# Parameters:
# *  port         - Bareos director configuration for Storage option 'SDPort'
# *  password     - Bareos director configuration for Storage option 'Password'
# *  device_name  - Bareos director configuration for Storage option 'Device'
# *  media_type   - Bareos director configuration for Storage option 'Media Type'
# *  maxconcurjob - Bareos director configuration for Storage option 'Media Type'
#
define bareos::director::storage (
  $port          = '9103',
  $password      = 'secret',
  $device_name   = "${::fqdn}-device",
  $media_type    = 'File',
  $maxconcurjobs = '1',
  $conf_dir      = $bareos::params::conf_dir, # Overridden at realize
) {

  include bareos::params

  concat::fragment { "bareos-director-storage-${name}":
    target  => "${conf_dir}/conf.d/storage.conf",
    content => template('bareos/bareos-dir-storage.erb'),
  }
}

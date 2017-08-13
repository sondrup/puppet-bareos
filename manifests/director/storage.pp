# This define creates a storage declaration for the director.  This informs the
# director which storage servers are available to send client backups to.
#
# This resource is intended to be used from bareos::storage as an exported
# resource, so that each storage server is available as a configuration on the
# director.
#
# @param port         - Bareos director configuration for Storage option 'SDPort'
# @param password     - Bareos director configuration for Storage option 'Password'
# @param device_name  - Bareos director configuration for Storage option 'Device'
# @param media_type   - Bareos director configuration for Storage option 'Media Type'
# @param maxconcurjob - Bareos director configuration for Storage option 'Media Type'
#
define bareos::director::storage (
  String $address                = $name,
  Integer[1] $port               = 9103,
  String $password               = 'secret',
  String $device_name            = "${::fqdn}-device",
  String $media_type             = 'File',
  Integer[1] $maxconcurjobs      = 1,
  Stdlib::Absolutepath $conf_dir = $bareos::conf_dir, # Overridden at realize
) {

  concat::fragment { "bareos-director-storage-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "210-${name}",
    content => template('bareos/bareos-dir-storage.erb'),
  }
}

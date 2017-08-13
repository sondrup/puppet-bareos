# This define creates a storage device declaration.  This informs the
# storage daemon which storage devices are available to send client backups to.
#
# @param device_name     - Bareos director configuration for Device option 'Name'
# @param media_type      - Bareos director configuration for Device option 'Media Type'
# @param device          - Bareos director configuration for Device option 'Archive Device'
# @param label_media     - Bareos director configuration for Device option 'LabelMedia'
# @param random_access   - Bareos director configuration for Device option 'Random Access'
# @param automatic_mount - Bareos director configuration for Device option 'AutomaticMount'
# @param removable_media - Bareos director configuration for Device option 'RemovableMedia'
# @param always_open     - Bareos director configuration for Device option 'AlwaysOpen'
# @param maxconcurjobs   - Bareos director configuration for Device option 'Maximum Concurrent Jobs'
# @param conf_dir
# @param device_mode
# @param device_owner
# @param device_seltype
# @param director_name
# @param group
#
define bareos::storage::device (
  String $device_name            = $name,
  String $media_type             = 'File',
  String $device                 = '/bareos',
  Bareos::Yesno $label_media     = 'yes',
  Bareos::Yesno $random_access   = 'yes',
  Bareos::Yesno $automatic_mount = 'yes',
  Bareos::Yesno $removable_media = 'no',
  Bareos::Yesno $always_open     = 'no',
  Integer[1] $maxconcurjobs      = 1,
  Stdlib::Absolutepath $conf_dir = $::bareos::conf_dir,
  String $device_mode            = '0770',
  String $device_owner           = $bareos::bareos_user,
  String $device_seltype         = $bareos::device_seltype,
  String $director_name          = $bareos::director_name,
  String $group                  = $bareos::bareos_group,
) {

  concat::fragment { "bareos-storage-device-${name}":
    target  => "${conf_dir}/bareos-sd.conf",
    content => template('bareos/bareos-sd-device.erb'),
  }

  if $media_type == 'File' {
    file { $device:
      ensure  => directory,
      owner   => $device_owner,
      group   => $group,
      mode    => $device_mode,
      seltype => $device_seltype,
    }
  }
}

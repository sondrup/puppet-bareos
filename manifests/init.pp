# This class is here to hold the data about a bareos instalation.  The
# parameters in this class are intended to be configured through hiera.  Other
# module classes will reference the values here.
#
# @param bareos_group The posix group for bareos.
# @param bareos_user The posix user for bareos.
# @param conf_dir The path to the bareos configuration directory.
# @param device_seltype SELinux type for the device
# @param director_name
# @param director_address
# @param homedir The bareos user's home directory path
# @param homedir_mode The bareos user's home director mode
# @param job_tag A tag to add to all job resources
# @param monitor Enable the Bareos Monitor option
# @param rundir The run dir for the daemons
# @param storage_name
# @param use_ssl Configure SSL, see README
#
# @example
#   include bareos
#
# TODO director_address is confusing, and is only used by the bconsole template
# TODO Document the use of storage_name
# TODO Document the use of director_name
#
class bareos (
  String $conf_dir,
  String $bareos_user,
  String $bareos_group,
  String $homedir,
  String $rundir,
  String $director_address,
  String $director_name,
  String $storage_name,
  String $homedir_mode      = '0770',
  Boolean $monitor          = true,
  String $device_seltype    = 'bareos_store_t',
  Boolean $use_ssl          = false,
  Optional[String] $job_tag = undef,
){

  if $use_ssl {
    include ::bareos::ssl
  }
}

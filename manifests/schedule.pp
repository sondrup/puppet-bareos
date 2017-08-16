# Creates a schedule to which jobs and jobdefs can adhere.
#
# @param runs A list of Bareos Run directives
# @param conf_dir Path to bareos configuration directory
#
# @example
#   bareos::schedule { 'Regularly':
#     runs => [
#       'Level=Incremental monday-saturday at 12:15',
#       'Level=Incremental monday-saturday at 0:15',
#       'Level=Full sunday at 0:05',
#     ]
#   }
#
define bareos::schedule (
  Array[String] $runs,
  Stdlib::Absolutepath $conf_dir = $bareos::conf_dir,
) {

  concat::fragment { "bareos-schedule-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "110-${name}",
    content => template('bareos/schedule.conf.erb'),
  }
}

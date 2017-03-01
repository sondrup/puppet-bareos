# Define: bareos::schedule
#
# Creates a schedule to which jobs and jobdefs can adhere.
#
define bareos::schedule (
  Array $runs,
  Stdlib::Absolutepath $conf_dir = $bareos::params::conf_dir,
) {

  concat::fragment { "bareos-schedule-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "110-${name}",
    content => template('bareos/schedule.conf.erb'),
  }
}

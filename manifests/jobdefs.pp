# Define: bareos::jobdefs
#
# This define adds a jobdefs entry on the bareos director for reference by the client configurations.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
define bareos::jobdefs (
  String $sched                     = 'Default',
  String $messages                  = 'Standard',
  Integer[1] $priority              = 10,
  String $pool                      = 'Default',
  Bareos::Job::Level $level         = undef,
  Bareos::Job::Type $jobtype        = 'Backup',
  Bareos::Yesno $accurate           = 'no',
  Boolean $reschedule_on_error      = false,
  Bareos::Time $reschedule_interval = '1 hour',
  Integer[1] $reschedule_times      = 10,
) {

  include ::bareos::params
  $conf_dir = $bareos::params::conf_dir

  concat::fragment { "bareos-jobdefs-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "610-${name}",
    content => template('bareos/jobdefs.conf.erb'),
  }
}

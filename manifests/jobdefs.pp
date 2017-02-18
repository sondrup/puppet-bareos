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
  $jobtype             = 'Backup',
  $sched               = 'Default',
  $messages            = 'Standard',
  $priority            = '10',
  $pool                = 'Default',
  $level               = undef,
  $accurate            = 'no',
  $reschedule_on_error = false,
  $reschedule_interval = '1 hour',
  $reschedule_times    = '10',
) {

  validate_re($jobtype, ['^Backup', '^Restore', '^Admin', '^Verify', '^Copy', '^Migrate'])

  include bareos::params
  $conf_dir = $bareos::params::conf_dir

  concat::fragment { "bareos-jobdefs-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "610-${name}",
    content => template('bareos/jobdefs.conf.erb'),
  }
}

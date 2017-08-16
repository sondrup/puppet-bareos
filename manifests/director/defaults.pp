# Some default resources for the bareos director.  These are referenced by
# defaults in other parts of this module, but need not be used.  They are here
# to ensure that the simple case of deploying a director and storage on the
# same machine, allows clients to receive the correct configuration.
#
class bareos::director::defaults (
  Hash $jobdefs                = {},
  Array[String] $schedule_runs = [],
  Hash $pool                   = {},
) {

  bareos::jobdefs { 'Default':
    jobtype => 'Backup',
    sched   => 'Default',
    *       => $jobdefs,
  }

  bareos::schedule { 'Default':
    runs => $schedule_runs,
  }

  bareos::director::pool { 'Default':
    pool_type        => 'Backup',
    label            => 'Default-',
    storage          => $bareos::director::storage_name,
    *                => $pool,
  }
}

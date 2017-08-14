# Some default resources for the bareos director.  These are referenced by
# defaults in other parts of this module, but need not be used.  They are here
# to ensure that the simple case of deploying a director and storage on the
# same machine, allows clients to receive the correct configuration.
#
class bareos::director::defaults {

  bareos::jobdefs { 'Default': }

  bareos::schedule { 'Default':
    runs => [
      'Level=Full sun at 2:05',
      'Level=Incremental mon-sat at 2:05',
    ],
  }

  bareos::director::pool { 'Default':
    pool_type => 'Backup',
    label     => 'Default-',
    storage   => $bareos::director::storage_name,
  }
}

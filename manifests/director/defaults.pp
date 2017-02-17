#: Class bacul::director::defaults
#
# Some default valuse for the bareos director
#
class bareos::director::defaults {

  bareos::jobdefs { 'Default': }

  bareos::schedule { 'Default':
    runs => [
      'Level=Full sun at 2:05',
      'Level=Incremental mon-sat at 2:05'
    ]
  }
}

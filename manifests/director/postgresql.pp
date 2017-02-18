# Class: bareos::director::postgresql
#
# Deploys a postgres database server for hosting the Bareos director
# database.
#
# Sample Usage:
#
#   none
#
class bareos::director::postgresql(
  String $make_bareos_tables = '',
  String $db_name            = $bareos::director::db_name,
  String $db_pw              = $bareos::director::db_pw,
  String $db_user            = $bareos::director::db_user,
  String $user               = $bareos::params::bareos_user,
) inherits bareos::params {

  require postgresql::server

  postgresql::server::db { $db_name:
    user     => $db_user,
    password => postgresql_password($db_user, $db_pw),
    encoding => 'SQL_ASCII',
    locale   => 'C',
  }

  exec { "/bin/sh ${make_bareos_tables}":
    user        => $user,
    refreshonly => true,
    environment => ["db_name=${db_name}"],
    subscribe   => Postgresql::Server::Db[$db_name],
    notify      => Service['bareos-director'],
    require     => [
      Postgresql::Server::Db[$db_name],
    ]
  }
}

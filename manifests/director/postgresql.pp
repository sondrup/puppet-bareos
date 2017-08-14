# Deploys a postgres database server for hosting the Bareos director database.
#
# @param make_bareos_tables
# @param db_name
# @param db_pw
# @param db_user
#
class bareos::director::postgresql(
  String $make_bareos_tables     = '',
  String $db_name                = $bareos::director::db_name,
  String $db_pw                  = $bareos::director::db_pw,
  String $db_user                = $bareos::director::db_user,
  Stdlib::Absolutepath $conf_dir = $bareos::conf_dir,
) {

  include ::bareos

  $user = $::bareos::bareos_user

  if $bareos::director::manage_db {
    require ::postgresql::server
    postgresql::server::db { $db_name:
      user     => $db_user,
      password => postgresql_password($db_user, $db_pw),
      encoding => 'SQL_ASCII',
      locale   => 'C',
      notify   => Exec["/bin/sh ${make_bareos_tables}"],
    }
  }

  exec { "/bin/sh ${make_bareos_tables}":
    user        => $user,
    refreshonly => true,
    environment => ["db_name=${db_name}"],
    require     => File["${conf_dir}/bareos-dir.conf"],
    notify      => Service['bareos-director'],
  }
}

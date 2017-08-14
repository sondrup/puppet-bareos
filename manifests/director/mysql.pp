# Deploys a mysql database server for hosting the Bareos director database.
#
# @param make_bareos_tables
# @param db_name
# @param db_pw
# @param db_user
#
class bareos::director::mysql(
  String $make_bareos_tables     = '',
  String $db_name                = $bareos::director::db_name,
  String $db_pw                  = $bareos::director::db_pw,
  String $db_user                = $bareos::director::db_user,
  Stdlib::Absolutepath $conf_dir = $bareos::conf_dir,
) {

  include ::bareos

  $user = $::bareos::bareos_user

  if $bareos::director::manage_db {
    require ::mysql::server
    mysql::db { $db_name:
      ensure   => present,
      user     => $db_user,
      password => $db_pw,
      grant    => 'ALL',
      charset  => 'utf8',
      collate  => 'utf8_bin',
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

# Class: bareos::postgres
#
# This class creates a define that creates a cron job to backup postgres databases
#
# Parameters:
#
# Actions:
#   - A define that creates a cron job to backup postgres databases
#
# Requires:
#
# Sample Usage:
#
# bareos::postgres { database_name: }
#
define bareos::postgres {

  include ::bareos::params
  include ::bareos::postgres::resources

  $homedir = $bareos::params::homedir

  cron { "bareos_postgres_${name}":
    command => "/bin/su -l postgres -c '/usr/bin/pg_dump ${name} --blobs --format=plain --create' | /bin/cat > ${homedir}/postgres/${name}.sql",
    user    => 'root',
    hour    => 0,
    minute  => 35,
    require => File["${homedir}/postgres"],
  }

  bareos::job { "${::fqdn}-postgres-${name}":
    files => "${homedir}/postgres/${name}.sql",
  }
}

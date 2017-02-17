# Define: bareos::fileset
#
# A grouping of files to backup.
#
define bareos::fileset (
  $files,
  $excludes                     = '',
  Hash[String, String] $options = {'signature' => 'SHA1', 'compression' => 'GZIP9'},
  $conf_dir                     = $bareos::params::conf_dir, # Overridden at realize
) {

  include bareos::common

  @@concat::fragment { "bareos-fileset-${name}":
    target  => "${conf_dir}/conf.d/fileset.conf",
    content => template('bareos/fileset.conf.erb'),
    tag     => "bareos-${::bareos::params::director}",
  }
}

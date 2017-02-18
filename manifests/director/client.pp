define bareos::director::client (
  $port           = '9102',
  $client         = $::fqdn,
  $password       = 'secret',
  $conf_dir       = $bareos::params::conf_dir, # Overridden at realize
  $file_retention = $bareos::params::file_retention,
  $job_retention  = $bareos::params::job_retention,
  $autoprune      = $bareos::params::autoprune,
) {

  concat::fragment { "bareos-director-client-${client}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "410-${client}",
    content => template('bareos/bareos-dir-client.erb'),
  }
}

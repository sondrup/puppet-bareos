define bareos::director::client (
  Integer[1] $port               = 9102,
  String $client                 = $::fqdn,
  String $password               = 'secret',
  Stdlib::Absolutepath $conf_dir = $bareos::params::conf_dir, # Overridden at realize
  Bareos::Time $file_retention   = $bareos::params::file_retention,
  Bareos::Time $job_retention    = $bareos::params::job_retention,
  Bareos::Yesno $autoprune       = $bareos::params::autoprune,
) {

  concat::fragment { "bareos-director-client-${client}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "410-${client}",
    content => template('bareos/bareos-dir-client.erb'),
  }
}

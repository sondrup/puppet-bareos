define bareos::director::job (
  String $content,
  Stdlib::Absolutepath $conf_dir = $bareos::params::conf_dir, # Overridden at realize
) {

  concat::fragment { "bareos-director-job-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "710-${name}",
    content => $content,
    tag     => "bareos-${::bareos::params::director}",
  }
}

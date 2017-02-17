define bareos::director::job (
  $content,
  $conf_dir = $bareos::params::conf_dir, # Overridden at realize
) {

  concat::fragment { "bareos-director-job-${name}":
    target  => "${conf_dir}/conf.d/job.conf",
    content => $content,
    tag     => "bareos-${::bareos::params::director}",
    order   => $name,
  }
}

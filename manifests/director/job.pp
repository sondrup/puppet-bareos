# This define handles the director portion of a job.  This define should not be
# used directly.  It is intended to be used only from the `bareos::job` define.
#
# This makes it simpler for the director to realize and override the conf_dir
# setting, so that the client conf_dir and the director conf_dir can differ,
# which is useful in a multi platform environment.
#
# @param content The full content of the job definition
# @param conf_dir Overridden at realize, should not need adjusting
#
# @example from bareos::job
#   @@bareos::director::job { $name:
#     content => template($template),
#     tag     => $real_tags,
#   }
#
define bareos::director::job (
  $content,
  $conf_dir = $bareos::conf_dir,
) {

  include ::bareos

  concat::fragment { "bareos-director-job-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    content => $content,
    order   => $name,
    tag     => "bareos-${::bareos::director_name}",
  }
}

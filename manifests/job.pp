# Define: bareos::job
#
# This class installs a bareos job on the director.  This can be used for specific applications as well as general host backups
#
# Parameters:
#   * files - An array of files that you wish to get backed up on this job for
#     this host.  ie: ["/etc","/usr/local"]
#   * excludes - An array of files to skip for the given job.
#     ie: ["/usr/local/src"]
#   * fileset - If set to true, a fileset will be genereated based on the files
#     and exclides paramaters specified above. If set to false, the
#     job will attempt to use the fileset named "Common". If set to anything
#     else, provided it's a String, that named fileset will be used.
#     NOTE: the fileset Common or the defined fileset must be declared elsewhere
#     for this to work. See Class::Bareos for details.
#   * runscript - Array of hash(es) containing RunScript directives.
#   * reshedule_on_error - boolean for enableing disabling job option "Reschedule On Error"
#   * reshedule_interval - string time-spec for job option "Reschedule Interval"
#   * reshedule_times - string count for job option "Reschedule Times"
#   * messages - string containing the name of the message resource to use for this job
#     set to false to disable this option
#   * restoredir - string containing the prefix for restore jobs
#   * sched - string containing the name of the scheduler
#     set to false to disable this option
#   * priority - string containing the priority number for the job
#     set to false to disable this option
#   * job_tag - string that might be used for grouping of jobs. Pass this to
#     bareos::director to only collect jobs that match this tag.
#
# Actions:
#   * Exports job fragment for consuption on the director
#
# Requires:
#   * Class::Bareos {}
#
# Sample Usage:
#  bareos::job { "${fqdn}-common":
#    fileset => "Root",
#  }
#
#  bareos::job { "${fqdn}-mywebapp":
#    files    => ["/var/www/mywebapp","/etc/mywebapp"],
#    excludes => ["/var/www/mywebapp/downloads"],
#  }
#
define bareos::job (
  Array $files                                         = [],
  Array $excludes                                      = [],
  Bareos::Job::Type $jobtype                           = 'Backup',
  Variant[Boolean, String] $fileset                    = true,
  String $template                                     = 'bareos/job.conf.erb',
  String $pool                                         = $bareos::client::default_pool,
  Boolean $pool_full                                   = $bareos::client::default_pool_full,
  Boolean $pool_inc                                    = $bareos::client::default_pool_inc,
  Boolean $pool_diff                                   = $bareos::client::default_pool_diff,
  Optional[String] $storage                            = undef,
  Optional[String] $jobdef                             = 'Default',
  Array $runscript                                     = [],
  Optional[Bareos::Job::Level] $level                  = undef,
  Bareos::Yesno $accurate                              = 'no',
  Boolean $reschedule_on_error                         = false,
  Bareos::Time $reschedule_interval                    = '1 hour',
  Integer[1] $reschedule_times                         = 10,
  Optional[String] $messages                           = undef,
  String $restoredir                                   = '/tmp/bareos-restores',
  Optional[String] $sched                              = undef,
  Optional[String] $priority                           = undef,
  String $job_tag                                      = $bareos::params::job_tag,
  Optional[Bareos::Job::Selectiontype] $selection_type = undef,
  Optional[String] $selection_pattern                  = undef,
) {

  include bareos::common
  include bareos::params
  $conf_dir = $bareos::params::conf_dir

  # if the fileset is not defined, we fall back to one called "Common"
  if is_string($fileset) {
    $fileset_real = $fileset
  } elsif $fileset == true {
    if $files == '' { err('you tell me to create a fileset, but no files given') }
    $fileset_real = $name
    bareos::fileset { $name:
      files    => $files,
      excludes => $excludes
      }
  } else {
    $fileset_real = 'Common'
  }

  if empty($job_tag) {
    $real_tags = "bareos-${::bareos::params::director}"
  } else {
    $real_tags = ["bareos-${::bareos::params::director}", $job_tag]
  }

  @@bareos::director::job { $name:
    content => template($template),
    tag     => $real_tags,
  }
}

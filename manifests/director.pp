# Class: bareos::director
#
# This class installs and configures the Bareos Backup Director
#
# Parameters:
# * db_user: the database user
# * db_pw: the database user's password
# * db_name: the database name
# * password: password to connect to the director
#
# Sample Usage:
#
#   class { 'bareos::director':
#     storage => 'mystorage.example.com'
#   }
#
class bareos::director (
  $port                = '9101',
  $listen_address      = $::ipaddress,
  $db_user             = $bareos::params::bareos_user,
  $db_pw               = 'notverysecret',
  $db_name             = $bareos::params::bareos_user,
  $db_type             = $bareos::params::db_type,
  $password            = 'secret',
  $max_concurrent_jobs = '20',
  $packages            = $bareos::params::bareos_director_packages,
  $services            = $bareos::params::bareos_director_services,
  $homedir             = $bareos::params::homedir,
  $rundir              = $bareos::params::rundir,
  $conf_dir            = $bareos::params::conf_dir,
  $director            = $::fqdn, # director here is not params::director
  $director_address    = $bareos::params::director_address,
  $storage             = $bareos::params::storage,
  $group               = $bareos::params::bareos_group,
  $job_tag             = $bareos::params::job_tag,
  $messages,
) inherits bareos::params {

  include bareos::common
  include bareos::client
  include bareos::ssl
  include bareos::director::defaults
  include bareos::virtual

  case $db_type {
    /^(pgsql|postgresql)$/: { include bareos::director::postgresql }
    'none': { }
    default:                { fail('No db_type set') }
  }

  realize(Package[$packages])

  service { $services:
    ensure    => running,
    enable    => true,
    subscribe => File[$bareos::ssl::ssl_files],
    require   => Package[$packages],
  }

  file { "${conf_dir}/conf.d":
    ensure => directory,
  }

  file { "${conf_dir}/bconsole.conf":
    owner     => 'root',
    group     => $group,
    mode      => '0640',
    show_diff => false,
    content   => template('bareos/bconsole.conf.erb');
  }

  Concat {
    owner  => 'root',
    group  => $group,
    mode   => '0640',
    notify => Service[$services],
  }

  concat::fragment { 'bareos-director-header':
    order   => '00',
    target  => "${conf_dir}/bareos-dir.conf",
    content => template('bareos/bareos-dir-header.erb')
  }

  concat::fragment { 'bareos-director-tail':
    order   => '99999',
    target  => "${conf_dir}/bareos-dir.conf",
    content => template('bareos/bareos-dir-tail.erb')
  }

  create_resources(bareos::messages, $messages)

  Bareos::Director::Pool <<||>> { conf_dir => $conf_dir }
  Bareos::Director::Storage <<| tag == "bareos-${storage}" |>> { conf_dir => $conf_dir }
  Bareos::Director::Client <<| tag == "bareos-${director}" |>> { conf_dir => $conf_dir }

  if !empty($job_tag) {
    Bareos::Fileset <<| tag == $job_tag |>> { conf_dir => $conf_dir }
    Bareos::Director::Job <<| tag == $job_tag |>> { conf_dir => $conf_dir }
  } else {
    Bareos::Fileset <<||>> { conf_dir => $conf_dir }
    Bareos::Director::Job <<||>> { conf_dir => $conf_dir }
  }


  Concat::Fragment <<| tag == "bareos-${director}" |>>

  concat { "${conf_dir}/bareos-dir.conf":
    show_diff => false,
  }

  $sub_confs = [
    "${conf_dir}/conf.d/schedule.conf",
    "${conf_dir}/conf.d/pools.conf",
    "${conf_dir}/conf.d/job.conf",
    "${conf_dir}/conf.d/jobdefs.conf",
    "${conf_dir}/conf.d/fileset.conf",
  ]

  $sub_confs_with_secrets = [
    "${conf_dir}/conf.d/client.conf",
    "${conf_dir}/conf.d/storage.conf",
  ]

  concat { $sub_confs: }

  concat { $sub_confs_with_secrets:
    show_diff => false,
  }

  bareos::fileset { 'Common':
    files => ['/etc'],
  }

  bareos::job { 'RestoreFiles':
    jobtype  => 'Restore',
    fileset  => false,
    jobdef   => false,
    messages => 'Standard',
  }
}

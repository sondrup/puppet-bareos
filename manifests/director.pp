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
  Integer[1] $port                = 9101,
  String $listen_address          = $::ipaddress,
  String $db_user                 = $bareos::params::bareos_user,
  String $db_pw                   = 'notverysecret',
  String $db_name                 = $bareos::params::bareos_user,
  Bareos::Dbdriver $db_type       = $bareos::params::db_type,
  String $db_address              = '127.0.0.1',
  String $password                = 'secret',
  Integer[1] $max_concurrent_jobs = 20,
  Array[String] $packages         = $bareos::params::bareos_director_packages,
  String $service                 = $bareos::params::bareos_director_service,
  Stdlib::Absolutepath $homedir   = $bareos::params::homedir,
  Stdlib::Absolutepath $rundir    = $bareos::params::rundir,
  Stdlib::Absolutepath $conf_dir  = $bareos::params::conf_dir,
  String $director                = $::fqdn, # director here is not params::director
  String $director_address        = $bareos::params::director_address,
  String $storage                 = $bareos::params::storage,
  String $group                   = $bareos::params::bareos_group,
  String $job_tag                 = $bareos::params::job_tag,
  Stdlib::Absolutepath $bin       = $bareos::params::bareos_director_bin,
  Boolean $validate_config        = true,
  Hash $messages,
  Boolean $include_repo           = true,
  Boolean $install                = true,
) inherits bareos::params {

  include bareos::common
  include bareos::client
  include bareos::ssl
  include bareos::director::defaults
  include bareos::virtual

  if $include_repo {
    include '::bareos::repo'
  }

  case $db_type {
    'postgresql': { include bareos::director::postgresql }
    'none':       { }
    default:      { fail('No db_type set') }
  }

  if $install {
    realize(Package[$packages])
  }

  service { 'bareos-director':
    name      => $service,
    ensure    => running,
    enable    => true,
    subscribe => File[$bareos::ssl::ssl_files],
    require   => Package[$packages],
  }

  file { "${conf_dir}/bconsole.conf":
    owner     => 'root',
    group     => $group,
    mode      => '0640',
    show_diff => false,
    content   => template('bareos/bconsole.conf.erb');
  }

  $validate_cmd = $validate_config ? {
    false   => undef,
    default => shell_join([$bin, '-t', '-c', '%']),
  }

  concat { "${conf_dir}/bareos-dir.conf":
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    warn           => true,
    show_diff      => false,
    require        => Package[$packages],
    notify         => Service['bareos-director'],
    validate_cmd   => $validate_cmd,
  }

  Concat::Fragment {
    target  => "${conf_dir}/bareos-dir.conf",
  }

  concat::fragment { 'bareos-director-header':
    order   => '00',
    content => template('bareos/bareos-dir-header.erb')
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

  $sub_confs = {
    'Schedule' => '100',
    'Storage'  => '200',
    'Pools'    => '300',
    'Client'   => '400',
    'Fileset'  => '500',
    'Jobdefs'  => '600',
    'Job'      => '700',
  }

  $sub_confs.each |$config_group, $order| {
    concat::fragment { "${config_group}-head":
      order   => $order,
      content => "\n\n# ${config_group} config\n\n",
    }
  }

  bareos::fileset { 'Common':
    files => ['/etc'],
  }

  bareos::job { 'RestoreFiles':
    jobtype  => 'Restore',
    fileset  => false,
    jobdef   => undef,
    messages => 'Standard',
  }
}

# This class installs and configures the Bareos Director
#
# @param conf_dir
# @param db_name: the database name
# @param db_pw: the database user's password
# @param db_type
# @param db_user: the database user
# @param director
# @param director_address
# @param group
# @param homedir
# @param job_tag A string to use when realizing jobs and filesets
# @param listen_address
# @param max_concurrent_jobs
# @param messages
# @param packages
# @param password
# @param password: password to connect to the director
# @param port The listening port for the Director
# @param rundir
# @param service
# @param bin
# @param storage_name
# @param manage_db
# @param db_address
# @param db_port
#
# @example
#   class { 'bareos::director':
#     storage => 'mystorage.example.com'
#   }
#
# TODO director_address is only used by bconsole, and is confusing as director is likely the same
#
class bareos::director (
  Bareos::Dbdriver $db_type,
  Hash $messages,
  Array[String] $packages,
  String $service,
  Stdlib::Absolutepath $bin,
  Boolean $manage_db              = true,
  Stdlib::Absolutepath $conf_dir  = $bareos::conf_dir,
  String $db_name                 = 'bareos',
  String $db_pw                   = 'notverysecret',
  String $db_user                 = 'bareos',
  String $db_address              = '127.0.0.1',
  Optional[Integer[1]] $db_port   = undef,
  String $director_address        = $bareos::director_address,
  String $director                = $trusted['certname'], # director here is not bareos::director
  String $group                   = $bareos::bareos_group,
  Stdlib::Absolutepath $homedir   = $bareos::homedir,
  Optional[String] $job_tag       = $bareos::job_tag,
  String $listen_address          = $facts['ipaddress'],
  Integer[1] $max_concurrent_jobs = 20,
  String $password                = 'secret',
  Integer[1] $port                = 9101,
  Stdlib::Absolutepath $rundir    = $bareos::rundir,
  String $storage_name            = $bareos::storage_name,
  Boolean $validate_config        = true,
  Boolean $include_repo           = true,
  Boolean $install                = true,
) inherits ::bareos {

  include ::bareos::director::defaults

  if $include_repo {
    include '::bareos::repo'
  }

  case $db_type {
    'postgresql': { include ::bareos::director::postgresql }
    'mysql': { include ::bareos::director::mysql }
    'none':       { }
    default:      { fail('No db_type set') }
  }

  if $install {
    # Packages are virtual due to some platforms shipping the SD and Dir as
    # part of the same package.
    include ::bareos::virtual

    # Allow for package names to include EPP syntax for db_type
    $package_names = $packages.map |$p| {
      $package_name = inline_epp($p, {
        'db_type' => $db_type
      })
    }

    realize(Package[$package_names])

    Package[$package_names] -> Service['bareos-director']
  }

  service { 'bareos-director':
    ensure => running,
    name   => $service,
    enable => true,
  }

  if $::bareos::use_ssl == true {
    include ::bareos::ssl
    Service['bareos-director'] {
      subscribe => File[$::bareos::ssl::ssl_files],
    }
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
    owner        => 'root',
    group        => $group,
    mode         => '0640',
    warn         => true,
    show_diff    => false,
    require      => Package[$packages],
    notify       => Service['bareos-director'],
    validate_cmd => $validate_cmd,
  }

  Concat::Fragment {
    target  => "${conf_dir}/bareos-dir.conf",
  }

  concat::fragment { 'bareos-director-header':
    order   => '00',
    content => template('bareos/bareos-dir-header.erb'),
  }

  create_resources(bareos::messages, $messages)

  Bareos::Director::Pool <<||>> { conf_dir => $conf_dir }
  Bareos::Director::Storage <<| tag == "bareos-${director}" |>> { conf_dir => $conf_dir }
  Bareos::Director::Client <<| tag == "bareos-${director}" |>> { conf_dir => $conf_dir }

  if $job_tag {
    Bareos::Director::Fileset <<| tag == $job_tag |>> { conf_dir => $conf_dir }
    Bareos::Director::Job <<| tag == $job_tag |>> { conf_dir => $conf_dir }
    # TODO tag pool resources on export when job_tag is defined
    Bareos::Director::Pool <<|tag == $job_tag |>> { conf_dir => $conf_dir }
  } else {
    Bareos::Director::Fileset <<||>> { conf_dir => $conf_dir }
    Bareos::Director::Job <<||>> { conf_dir => $conf_dir }
    Bareos::Director::Pool <<||>> { conf_dir => $conf_dir }
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

  bareos::director::fileset { 'Common':
    files => ['/etc'],
  }

  bareos::job { 'RestoreFiles':
    jobtype             => 'Restore',
    jobdef              => undef,
    messages            => 'Standard',
    fileset             => 'Common',
    max_concurrent_jobs => $max_concurrent_jobs,
  }
}

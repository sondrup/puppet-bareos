# Bareos

[![Puppet Forge](https://img.shields.io/puppetforge/v/sondrup/bareos.svg)]() [![Build Status](https://travis-ci.org/sondrup/puppet-bareos.svg?branch=master)](https://travis-ci.org/sondrup/puppet-bareos)

A puppet module for the Bareos backup system.

## Supported Platforms

* Linux (Debian, Ubuntu)

# Requirements

This module requires that [exported resources] have been setup (e.g. with
[PuppetDB]).  Including manifests on the Bareos client, assumes that it can
export bits of data to the director to end up with fully functional configs.
As such, to get the benefits of using this module, you should be using it on at
least the director and client, and most likely the storage, though this might
be gotten around, if one were so inclined.

## Usage

To understand Bareos, the [Component Overview] in the Bareos documentation is a
useful start to begin understanding the moving parts.

### A Minimal Setup

What follows here is the bare minimum you would need to get a fully functional
Bareos environment with Puppet.  This setup assumes that the three components
of Bareos (Director, Storage, and Client) all run on three separate nodes.  If
desired, there is no reason this setup can not be built on a single node, just
updating the hostnames used below to all point to the same system.

#### Defaults

Bareos's functionality depends on connecting several components, together.  Due
to the number of moving pieces in this module, you will likely want to set some
site defaults, and tune more specifically where desired.

As such, it is reasonable to set the following hiera data that will allow 
many of the classes in this module to use those defaults sanely.

```
bareos::storage_name: 'mystorage.example.com'
bareos::director_name: 'mydirector.example.com'
```

##### Classification

This may be on the same host, or different hosts, but the name you put here 
should be the fqdn of the target system.  The Director will require the 
classification of `bareos::director`, and the Storage node will require the 
classification of `bareos::storage`.  **All nodes will require classification of
 `bareos::client`.**

##### Prefer hiera data

Users should prefer setting hiera data to set class parameter values where
possible.  A couple calls in this module rely on hiera data present to avoid
scoping issues associated with defined types and default values.

##### ** Upgrading to 5.x **

The `bareos::params` class has been completely removed.  Any data in your
primary hiera that used these values will need to be updated.

The variables used to specify the Storage and Director host have been moved.
Where previously, `bareos::params::director` and `bareos::params::storage`,
replace them with `bareos::director_name` and `bareos::storage_name`.

Here are is the list of variables that have moved out of the params class.  If
any of these are set in an environments hiera data, they will not be respected
and should be moved as follows.

- move bareos::params::file_retention to bareos::client::file_retention
- move bareos::params::job_retention to bareos::client::job_retention
- move bareos::params::autoprune to bareos::client::autoprune
- move bareos::client::director to bareos::client::director_name

- move bareos::params::monitor to bareos::monitor
- move bareos::params::device_seltype to bareos::device_seltype
- move bareos::params::ssl to bareos::use_ssl

- move bareos::params::ssl_dir to bareos::ssl::ssl_dir
- users are required to set baculs::ssl::ssl_dir

The following classes have been relocated as well.  Please update any
references of the former to reference the latter.

- move class bareos::fileset to bareos::director::fileset

Other data changes are as follows.

- remove needless bareos::client::storage
- Relocated many `params` variables to `bareos` class

##### ** Upgrading to 4.x **

Several params have been removed and replaced with the default names.  Update
your hiera data and parameters as follows.

The following have been replaced with simply `bareos::params::director`.

* `bareos::params::director_name`
* `bareos::params::bareos_director`
 
The following have been replaced with simply `bareos::params::storage`.

* `bareos::params::bareos_storage`
* `bareos::params::storage_name`

The default 'Full' and 'Inc' pools no longer get created.  Only the pool 
called 'Default' is created.  As such, the following parameter have been 
removed from the `bareos::storage` class.

*  `$volret_full`
*  `$volret_incremental`
*  `$maxvolbytes_full`
*  `$maxvoljobs_full`
*  `$maxvols_full`
*  `$maxvolbytes_incremental`
*  `$maxvoljobs_incremental`
*  `$maxvols_incremental`

This now means that Full jobs are not directed to a 'Full' pool, and 
Incremental jobs are no longer directed to an 'Inc' pool.

To gain the same functionality available in previous versions using a 
default pool for a specific level of backup, create a pool as directed below,
 and set any of the following parameters for your clients. 

* `bareos::client::default_pool_full`
* `bareos::client::default_pool_inc`
* `bareos::client::default_pool_diff`

The value of these parameters should be set to the resource name of the pool.

#### SSL

To enable SSL for the communication between the various components of Bareos,
the hiera data for SSL must be set.

```yaml
bareos::use_ssl: true
```

This will ensure that SSL values are processed in the various templates that
are capable of SSL communication.  An item of note: this module expects to be
using the SSL directory for Puppet.  The default value for the Puppet SSL
directory this module will use is `/etc/puppetlabs/puppet/ssl` to support the
future unified Puppet deployment.

To change the SSL directory, simply set `bareos::ssl::ssl_dir`.  For
example, to use another module for the data source of which SSL directory to
use for Puppet, something like the following is in order.

```yaml
bareos::ssl::ssl_dir: "%{scope('puppet::params::puppet_ssldir')}"
```

This example assumes that you are using the [ploperations/puppet] module, but
this has been removed as a dependency.  Users may also wish to look at 
[theforeman/puppet] or just set it to the location known to house your ssl 
data, like `/etc/puppetlabs/puppet/ssl`.

#### Director Setup

The director component handles coordination of backups and databasing of
transactions.  In its simplest form, the director can be configured with a
simple declaration:

```Puppet
class { 'bareos::director': storage => 'mystorage.example.com' }
```

The `storage` parameter here defines which storage server should be used for 
all default jobs.  If left empty, it will default to the `$::fqdn` of the 
director. This is not a problem for all in one installations, but in 
scenarios where directors to not have the necessary storage devices attached,
default jobs can be pointed elsewhere.  

Note that if you expect an SD to be located on the Director, you will 
also need to include the `bareos::storage` class as follows.

By default a 'Common' fileset is created.

#### Storage Setup

The storage component allocates disk storage for pools that can be used for
holding backup data.

```Puppet
class { 'bareos::storage': director => 'mydirector.example.com' }
```

You will also want a storage pool that defines the retention.  You can define
 this in the Director catalog without exporting it, or you can use an 
 exported resource.

```Puppet
  bareos::director::pool { 'Corp':
    volret      => '14 days',
    maxvolbytes => '5g',
    maxvols     => '200',
    label       => 'Corp-',
    storage     => 'mystorage.example.com',
  }
```

#### Client Setup

The client component is run on each system that needs something backed up.

```Puppet
class { 'bareos::client': director => 'mydirector.example.com' }
```

To direct all jobs to a specific pool like the one defined above set the 
following data. 

```Puppet
bareos::client::default_pool: 'Corp'
```

## Creating Backup Jobs

In order for clients to be able to define jobs on the director, exported
resources are used, thus there was a reliance on PuppetDB availability in the
environment. In the client manifest the `bareos::job` exports a job 
definition to the director. If you deploy multiple directors that use the
same PuppetDB and you don't want each director to collect every job, specify
a job_tag to group them.

```puppet
bareos::job { 'obsidian_logs':
  files => ['/var/log'],
}
```

This resource will create a new `Job` entry in `/etc/bareos/bareos-dir.conf`
the next time the director applies it's catalog that will instruct the system
to backup the files or directories at the paths specified in the `files` 
parameter.

If a group of jobs will contain the same files, a [FileSet resource] can be
used to simplify the `bareos::job` resource. This can be exported from the
node (ensuring the resource title will be unique when realized) or a simple
resource specified on the director using the `bareos::fileset` defined type as
follows:

```puppet
bareos::fileset { 'Puppet':
  files   => ['/etc/puppet'],
  options => {'compression' => 'LZO' }
}
```
If you set a job_tag on your `bareos::job`, make sure to also set the tag of
the `bareos::fileset` to the same value.

## Available types

### bareos::fileset

Defines a Bareos [FileSet resource]. Parameters are:

- `files`: string or array of files to backup.
   Bareos `File` directive.
- `excludes`: string or array of files to exclude from a backup.
  Defaults to `''`.  Bareos `Exclude` directive.
- `options`: hash of options.
  Defaults to `{'signature' => 'MD5', 'compression' => 'GZIP'}`.  Bareos `Options` directive.

### bareos::job

Define a Bareos [Job resource] resource which can create new `Bareos::Fileset`
resources if needed. Parameters are:

- `files`: array of files to backup as part of `Bareos::Fileset[$name]`
  Defaults to `[]`.
- `excludes`: array of files to exclude in `Bareos::Fileset[$name]`
  Defaults to `[]`.
- `jobtype`: one of `Backup` (default), `Restore`, `Admin`, `Verify`, `Copy` or `Migrate`.
  Defaults to `Backup`. Bareos `Type` directive.
- `fileset`: determines whether to use the `Common` fileset (`false`), define a
   new `Bareos::Fileset[$name]` (`true`) or use a previously
  defined `Bareos::Fileset` resource (any other string value).
  Defaults to `true`. Bareos `FileSet` directive.
- `template`: template to use for the fragment.
  Defaults to `bareos/job.conf.erb`.
- `pool`: name of the `bareos::director::pool` to use.
  Defaults to `bareos::client::default_pool`. Bareos `Pool` directive.
- `pool_full`: name of the pool to be used for 'Full' jobs.
  Defaults to `bareos::client::default_pool_full`. Bareos `Full Backup Pool`
   directive. 
- `pool_inc`: name of the pool to be used for 'Incremental' jobs.
  Defaults to `bareos::client::default_pool_inc`. Bareos `Incremental Backup Pool`
   directive. 
- `pool_diff`: name of the pool to be used for 'Incremental' jobs.
  Defaults to `bareos::client::default_pool_diff`. Bareos `Differential Backup Pool`
   directive. 
- `jobdef`: name of the `bareos::jobdef` to use.
  Defaults to `Default`. Bareos `JobDefs` directive.
- `level`: default job level to run the job as.
  Bareos `Level` directive.
- `accurate`: whether to enable accurate mode. NB, can be memory intensive
  on the client.
  Defaults to 'no'. Bareos 'Accurate' directive.
- `messages`: the name of the message resource to use for this job.
  Defaults to `false` which disables this directive. Bareos `Messages` directive.
  To ensure compatibility with existing installations, the Bareos `Messages`
  directive is set to `Standard` when `Jobtype` is `Restore` and the `messages`
  parameter is `false`.
- `restoredir`: the prefix for restore jobs.
  Defaults to `/tmp/bareos-restores`. Bareos `Where` directive.
- `sched`: the name of the scheduler resource to use for this job.
  Defaults to `false` which disables this directive. Bareos `Schedule` directive.
- `priority`: the priority of the job.
  Defaults to `false` which disables this directive. Bareos `Priority` directive.
- `selection_type`: determines how a copy/migration job will go about selecting what JobIds to migrate
- `selection_pattern`: gives you fine control over exactly what JobIds are selected for a copy/migration job.

See also `bareos::jobdefs`.

### bareos::jobdefs

Define a Bareos [JobDefs resource] resource. Parameters are:

- `jobtype`: one of `Backup`, `Restore`, `Admin`, `Verify`, `Copy` or `Migrate`.  Defaults to
  `Backup`. Bareos `Type` directive.
- `sched`: name of the `bareos::schedule` to use.  Defaults to `Default`.
  Bareos `Schedule` directive.
- `messages`: which messages resource to deliver to.  Defaults to `Standard`.
  Bareos `Messages` directive.
- `priority`: priority of the job.  Defaults to `10`. Bareos `Priority`
  directive.
- `pool`: name of the `bareos::director::pool` to use.  Defaults to `Default`.
  Bareos `Pool` directive.
- `level`: default job level for jobs using this JobDefs.  Bareos `Level`
  directive.
- `accurate`: whether to enable accurate mode. NB, can be memory intensive on
  the client.  Defaults to 'no'. Bareos 'Accurate' directive.
- `reschedule_on_error`: Enable rescheduling of failed jobs.  Default: false.
  Bareos `Reschedule On Error` directive.
- `reschedule_interval`: The time between retries for failed jobs.  Bareos
  `Reschedule Interval` directive.
- `reschedule_times`: The number of retries  for failed jobs.  Bareos
  `Reschedule Times` directive.

### bareos::messages

Define a Bareos [Messages resource]. Parameters are:

- `mname`: name of the `Messages` resource.
  Defaults to `Standard`. Bareos `Name` directive.
- `daemon`:
  Defaults to `dir`.
- `director`:
  Bareos `Director` directive.  Note this is not just the name of a director,
   but director string as found in the documentation for [Messages resource] 
   under the director option.  The message type must be included with the 
   proper formatting.
- `append`:
  Bareos `Append` directive.
- `Catalog`:
  Bareos `Catalog` directive.
- `syslog`:
  Bareos `Syslog` directive.
- `Console`:
  Bareos `Console` directive.
- `mail`:
  Bareos `Mail` directive.
- `Operator`:
  Bareos `Operator` directive.
- `mailcmd`:
  Bareos `Mail Command` directive.
- `operatorcmd`:
  Bareos `Operator Command` directive.

### bareos::schedule

Define a Bareos [Schedule resource]. Parameter is:

- `runs`: define when a job is run.
   Bareos `Run` directive.

### bareos::director::pool

Define a Bareos [Pool resource]. Parameters are:

- `pooltype`:
  Defaults to `Backup`. Bareos `Pool Type` directive.
- `recycle`
  Bareos `Recycle` directive.
- `autoprune`:
   Defaults to `Yes`. Bareos `AutoPrune` directive.
- `volret`:
  Bareos `Volume Retention` directive.
- `maxvols`:
  Bareos `Maximum Volumes` directive.
- `maxvoljobs`:
  Bareos `Maximum Volume Jobs` directive.
- `maxvolbytes`:
  Bareos `Maximum Volume Bytes` directive.
- `purgeaction`:
  Bareos `Action On Purge` directive.
  Defaults to `Truncate`.
- `label`:
  Bareos `Label Format` directive.
- `voluseduration`:
  Bareos `Volume Use Duration` directive.
- `storage`: name of the `Storage` resource backing the pool.
  Defaults to `$bareos::storage_name`. Bareos `Storage` directive.
- `next_pool`: specifies that data from a `Copy` or `Migrate` job should go to the provided pool


[Component Overview]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-60001.3
[FileSet resource]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-1400009.5
[exported resources]: https://docs.puppetlabs.com/puppet/latest/reference/lang_exported.html
[PuppetDB]: https://docs.puppetlabs.com/puppetdb
[JobDefs resource]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-1370009.3
[Pool resource]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-1500009.8
[Schedule resource]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-1380009.4
[Job resource]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-1360009.2
[Messages resource]: http://doc.bareos.org/master/html/bareos-manual-main-reference.html#x1-17300012
[ploperations/puppet]: https://forge.puppetlabs.com/ploperations/puppet
[theforeman/puppet]: https://forge.puppetlabs.com/theforeman/puppet


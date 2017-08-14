# Define: bareos::director::pool
#
# This define adds a pool to the bareos director configuration in the bareos-dir.conf
# file. This resources is intended to be used from bareos::storage as a way
# to export the pool resources to the director.
#
# @param pool_type        - Bareos pool configuration option "Pool Type"
# @param recycle          - Bareos pool configuration option "Recycle"
# @param autoprune        - Bareos pool configuration option "AutoPrune"
# @param volume_retention - Bareos pool configuration option "Volume Retention"
# @param max_volume_jobs  - Bareos pool configuration option "Maximum Volume Jobs"
# @param max_volume_bytes - Bareos pool configuration option "Maximum Volume Bytes"
# @param action_on_purge  - Bareos pool configuration option "Action On Purge"
# @param label            - Bareos pool configuration option "Label Format"
#
# @example
# bareos::director::pool {
#   "PuppetLabsPool-Full":
#     volume_retention => "2 months",
#     max_volume_bytes => '2000000000',
#     max_volume_jobs  => '10',
#     max_volumes      => "20",
#     label            => "Full-";
# }
#
define bareos::director::pool (
  Optional[Bareos::Time] $volume_retention    = undef,
  Optional[Integer[1]] $max_volume_jobs       = undef,
  Optional[String] $max_volume_bytes          = undef,
  Optional[Integer[1]] $max_volumes           = undef,
  Optional[String] $label                     = undef,
  Optional[Bareos::Time] $volume_use_duration = undef,
  String $storage                             = $bareos::director::storage,
  Bareos::Pool_type $pool_type                = 'Backup',
  Bareos::Yesno $recycle                      = 'yes',
  Bareos::Yesno $autoprune                    = 'yes',
  String $action_on_purge                     = 'Truncate',
  Optional[String] $next_pool                 = undef,
  Stdlib::Absolutepath $conf_dir              = $bareos::conf_dir,
) {

  concat::fragment { "bareos-director-pool-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "310-${name}",
    content => template('bareos/bareos-dir-pool.erb'),
  }
}

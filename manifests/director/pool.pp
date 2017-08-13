# Define: bareos::director::pool
#
# This define adds a pool to the bareos director configuration in the bareos-dir.conf
# file. This resources is intended to be used from bareos::storage as a way
# to export the pool resources to the director.
#
# @param pooltype    - Bareos pool configuration option "Pool Type"
# @param recycle     - Bareos pool configuration option "Recycle"
# @param autoprune   - Bareos pool configuration option "AutoPrune"
# @param volret      - Bareos pool configuration option "Volume Retention"
# @param maxvoljobs  - Bareos pool configuration option "Maximum Volume Jobs"
# @param maxvolbytes - Bareos pool configuration option "Maximum Volume Bytes"
# @param purgeaction - Bareos pool configuration option "Action On Purge"
# @param label       - Bareos pool configuration option "Label Format"
#
# @example
# bareos::director::pool {
#   "PuppetLabsPool-Full":
#     volret      => "2 months",
#     maxvolbytes => '2000000000',
#     maxvoljobs  => '10',
#     maxvols     => "20",
#     label       => "Full-";
# }
#
define bareos::director::pool (
  $volret                        = undef,
  $maxvoljobs                    = undef,
  $maxvolbytes                   = undef,
  $maxvols                       = undef,
  $label                         = undef,
  $voluseduration                = undef,
  String $storage                = $bareos::director::storage,
  $pooltype                      = 'Backup',
  $recycle                       = 'Yes',
  $autoprune                     = 'Yes',
  $purgeaction                   = 'Truncate',
  $next_pool                     = undef,
  Stdlib::Absolutepath $conf_dir = $bareos::conf_dir,
) {

  concat::fragment { "bareos-director-pool-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "310-${name}",
    content => template('bareos/bareos-dir-pool.erb'),
  }
}

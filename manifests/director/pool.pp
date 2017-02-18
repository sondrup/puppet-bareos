# Define: bareos::director::pool
#
# This define adds a pool to the bareos director configuration in the bareos-dir.conf
# file. This resources is intended to be used from bareos::storage as a way
# to export the pool resources to the director.
#
# Parameters:
# *  pooltype    - Bareos pool configuration option "Pool Type"
# *  recycle     - Bareos pool configuration option "Recycle"
# *  autoprune   - Bareos pool configuration option "AutoPrune"
# *  volret      - Bareos pool configuration option "Volume Retention"
# *  maxvoljobs  - Bareos pool configuration option "Maximum Volume Jobs"
# *  maxvolbytes - Bareos pool configuration option "Maximum Volume Bytes"
# *  purgeaction - Bareos pool configuration option "Action On Purge"
# *  label       - Bareos pool configuration option "Label Format"
#
# Actions:
#
# Requires:
#
# Sample Usage:
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
  $volret         = undef,
  $maxvoljobs     = undef,
  $maxvolbytes    = undef,
  $maxvols        = undef,
  $label          = undef,
  $voluseduration = undef,
  $storage        = $bareos::director::storage,
  $pooltype       = 'Backup',
  $recycle        = 'Yes',
  $autoprune      = 'Yes',
  $purgeaction    = 'Truncate',
  $conf_dir       = $bareos::params::conf_dir, # Overridden at realize
  $next_pool      = undef,
) {

  include bareos::params

  concat::fragment { "bareos-director-pool-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "310-${name}",
    content => template('bareos/bareos-dir-pool.erb'),
  }
}

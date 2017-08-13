# This class handles a Director's fileset.conf entry.  Filesets are intended to
# be included on the Director catalog.  Resources of this type may also be
# exported to be realized by the director.
#
# @param files
# @param conf_dir The bareos configuration director.  Should not need adjusting.
# @param excludes A list of paths to exclude from the filest
# @param options A hash of options to include in the fileset
# @param director_name The name of the director intended to receive this fileset.
#
# @example
#   bareos::director::fileset { 'Home':
#     files => ['/home'],
#   }
#
define bareos::director::fileset (
  Array[String] $files,
  Stdlib::Absolutepath $conf_dir                = $::bareos::conf_dir,
  String $director_name                         = $::bareos::director_name,
  Optional[Array] $excludes                     = [],
  Hash[String, Variant[String, Array]] $options = {
    'signature'   => 'SHA1',
    'compression' => 'GZIP9',
  },
) {

  concat::fragment { "bareos-fileset-${name}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "510-${name}",
    content => template('bareos/fileset.conf.erb'),
    tag     => "bareos-${director_name}",
  }
}

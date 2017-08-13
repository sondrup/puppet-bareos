# This define handles informing the director about a client.  This class should
# not be used directly, but only ever exported through the `bareos::client`
# define.  This is the director's configuration for a given client.
#
# @param port
# @param client
# @param password
# @param file_retention
# @param job_retention
# @param autoprune
# @param conf_dir
#
# @example Taken from the `bareos::client` define:
#   @@bareos::director::client { $client:
#     port           => $port,
#     client         => $client,
#     password       => $password,
#     autoprune      => $autoprune,
#     file_retention => $file_retention,
#     job_retention  => $job_retention,
#     tag            => "bareos-${director_name}",
#   }
#
define bareos::director::client (
  Integer[1] $port,
  String $client,
  String $password,
  Bareos::Time $file_retention,
  Bareos::Time $job_retention,
  Bareos::Yesno $autoprune,
  Stdlib::Absolutepath $conf_dir = $::bareos::conf_dir
) {

  concat::fragment { "bareos-director-client-${client}":
    target  => "${conf_dir}/bareos-dir.conf",
    order   => "410-${client}",
    content => template('bareos/bareos-dir-client.erb'),
  }
}

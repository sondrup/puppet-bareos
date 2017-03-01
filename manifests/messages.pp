# == Define: bareos::messages
#
# Create a Messages resource on the $daemon (director, storage or file).
#
define bareos::messages (
  String $mname                   = 'Standard',
  Enum['dir', 'sd', 'fd'] $daemon = 'dir',
  Optional[String] $director      = undef,
  Optional[String] $append        = undef,
  Optional[String] $catalog       = undef,
  Optional[String] $syslog        = undef,
  Optional[String] $console       = undef,
  Optional[String] $mail          = undef,
  Optional[String] $operator      = undef,
  Optional[String] $mailcmd       = undef,
  Optional[String] $operatorcmd   = undef,
) {

  include ::bareos::common
  include ::bareos::params

  concat::fragment { "bareos-messages-${daemon}-${name}":
    target  => "${bareos::params::conf_dir}/bareos-${daemon}.conf",
    content => template('bareos/messages.erb'),
  }
}

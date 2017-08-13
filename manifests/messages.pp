# Create a Messages resource on the $daemon (director, storage or file).
#
# @param append
# @param catalog
# @param console
# @param daemon
# @param director
# @param mailcmd
# @param mail
# @param mname
# @param operatorcmd
# @param operator
# @param syslog
#
define bareos::messages (
  Optional[String] $append        = undef,
  Optional[String] $catalog       = undef,
  Optional[String] $console       = undef,
  Enum['dir', 'sd', 'fd'] $daemon = 'dir',
  Optional[String] $director      = undef,
  Optional[String] $mailcmd       = undef,
  Optional[String] $mail          = undef,
  String $mname                   = 'Standard',
  Optional[String] $operatorcmd   = undef,
  Optional[String] $operator      = undef,
  Optional[String] $syslog        = undef,
) {

  include ::bareos
  include ::bareos::common

  concat::fragment { "bareos-messages-${daemon}-${name}":
    target  => "${bareos::conf_dir}/bareos-${daemon}.conf",
    content => template('bareos/messages.erb'),
  }
}

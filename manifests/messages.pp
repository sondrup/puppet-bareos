# == Define: bareos::messages
#
# Create a Messages resource on the $daemon (director, storage or file).
#
define bareos::messages (
  $mname       = 'Standard',
  $daemon      = 'dir',
  $director    = undef,
  $append      = undef,
  $catalog     = undef,
  $syslog      = undef,
  $console     = undef,
  $mail        = undef,
  $operator    = undef,
  $mailcmd     = undef,
  $operatorcmd = undef,
) {
  validate_re($daemon, ['^dir', '^sd', '^fd'])

  include bareos::common
  include bareos::params

  concat::fragment { "bareos-messages-${daemon}-${name}":
    target  => "${bareos::params::conf_dir}/bareos-${daemon}.conf",
    content => template('bareos/messages.erb'),
  }
}

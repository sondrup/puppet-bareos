class bareos::repo::debian (
  String[1] $version = 'latest',
  Hash $key          = {},
  Hash $source       = {},
) {
  include '::apt'

  $location  = "http://download.bareos.org/bareos/release/${version}/Debian_${facts['lsbmajdistrelease']}.0/"

  Apt::Key {
    id => '0143857D9CE8C2D182FE2631F93C028C093BFBA2',
    source => "${location}/Release.key",
  }

  Apt::Source {
    location => $location,
  }

  apt::key { 'bareos':
    before => Apt::Source['bareos'],
    *      => $key,
  }

  apt::source { 'bareos':
    require => Apt::Key['bareos'],
    *       => $source,
  }

  Apt::Source['bareos'] ~> Class['::apt::update'] -> Package <| tag == 'bareos' |>
}

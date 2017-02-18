class bareos::repo::debian (
  String[1] $version         = 'latest',
  Hash $key                  = {},
  Hash $setting              = {},
  Optional[String] $location = undef,
  String $operatingsystem    = $facts['operatingsystem'],
) {
  include '::apt'

  case $operatingsystem {
    'Ubuntu': {
      $distro = "xUbuntu_${facts['lsbmajdistrelease']}"
    }
    default: {
      $distro = "Debian_${facts['lsbmajdistrelease']}.0"
    }
  }

  if $location == undef {
    $_location = "http://download.bareos.org/bareos/release/${version}/${distro}/"
  } else {
    $_location = $location
  }

  $content = "deb ${_location} /"

  Apt::Key {
    id => '0143857D9CE8C2D182FE2631F93C028C093BFBA2',
    source => "${_location}/Release.key",
  }

  apt::key { 'bareos':
    *      => $key,
  }

  apt::setting { 'list-bareos':
    content       => $content,
    notify_update => true,
    *             => $setting,
  }

  Apt::Key['bareos'] -> Apt::Setting['list-bareos'] ~> Class['::apt::update'] -> Package <| tag == 'bareos' |>
}

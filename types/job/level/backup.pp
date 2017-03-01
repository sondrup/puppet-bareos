# Levels for Backup jobs
type Bareos::Job::Level::Backup = Enum[
  'Full',
  'Incremental',
  'Diﬀerential',
  'VirtualFull',
]

# Levels for Backup jobs
type Bareos::Job_level::Backup = Enum[
  'Full',
  'Incremental',
  'Diﬀerential',
  'VirtualFull',
]

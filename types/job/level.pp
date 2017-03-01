# Bareos BackupLevels
type Bareos::Job::Level = Variant[
  Bareos::Job::Level::Backup,
  Bareos::Job::Level::Restore,
  Bareos::Job::Level::Verify
]

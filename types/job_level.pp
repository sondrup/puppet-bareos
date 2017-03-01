# Bareos BackupLevels
type Bareos::Job_level = Variant[
  Bareos::Job_level::Backup,
  Bareos::Job_level::Restore,
  Bareos::Job_level::Verify,
]

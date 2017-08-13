type Bareos::JobType = Pattern[
  /^Backup/,
  /^Restore/,
  /^Admin/,
  /^Verify/,
  /^Copy/,
  /^Migrate/,
]

# Levels for Verify jobs
type Bareos::Job::Level::Verify = Enum[
  'InitCatalog',
  'Catalog',
  'VolumeToCatalog',
  'DiskToCatalog',
]

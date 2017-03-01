# Levels for Verify jobs
type Bareos::Job_level::Verify = Enum[
  'InitCatalog',
  'Catalog',
  'VolumeToCatalog',
  'DiskToCatalog',
]

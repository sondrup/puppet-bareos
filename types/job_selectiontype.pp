# Bareos Job Selection Type
type Bareos::Job_selectiontype = Enum[
  'SmallestVolume',
  'OldestVolume',
  'Client',
  'Volume',
  'Job',
  'SQLQuery',
  'PoolOccupancy',
  'PoolTime',
  'PoolUncopiedJobs',
]

# Bareos Job Selection Type
type Bareos::Job::Selectiontype = Enum[
  'SmallestVolume',
  'OldestVolume',
  'Client',
  'Volume',
  'Job',
  'SQLQuery',
  'PoolOccupancy',
  'PoolTime',
  'PoolUncopiedJobs'
]

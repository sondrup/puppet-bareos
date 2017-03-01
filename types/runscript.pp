type Bareos::Runscript = Struct[{
  runs_on_success   => Optional[Bareos::Yesno],
  runs_on_failure   => Optional[Bareos::Yesno],
  runs_on_client    => Optional[Bareos::Yesno],
  fail_job_on_error => Optional[Bareos::Yesno],
  runs_when         => Enum['Never', 'Before', 'After', 'Always', 'AfterVSS'],
  command           => String,
  console           => Optional[String],
}]

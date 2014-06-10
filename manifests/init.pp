# == Class: logaggregation
#
# Module to manage the EIS Log Aggregation client
#
class logaggregation(
  $package_name   = 'EISlogging',
  $package_ensure = 'installed',
) {

  package { $package_name:
    ensure => $package_ensure,
  }
}

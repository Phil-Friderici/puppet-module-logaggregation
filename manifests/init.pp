# == Class: logaggregation
#
# Module to manage the EIS Log Aggregation client
#
class logaggregation(
  $manage_packages = true,
  $package_name    = 'USE_DEFAULTS',
  $package_ensure  = 'installed',
) {

  validate_bool($manage_packages)

  if $manage_packages == true {

    case $::osfamily {
      'Debian': {
        $package_name_default = [ 'eislogging', 'eisloggingnfs', ]
      }
      'RedHat': {
        $package_name_default = [ 'EISlogging', 'EISloggingNFS', ]
      }
      'Suse': {
        $package_name_default = [ 'EISlogging', 'EISloggingNFS', ]
      }
      default: {
        fail("logaggregation support package management on osfamilies Debian, RedHat and Suse. Please set logaggregation::manage_packages to <false> for <${::osfamily}> hosts.")
      }
    }

    if $package_name == 'USE_DEFAULTS' {
      $package_name_real = $package_name_default
    } else {
      $package_name_real = any2array($package_name)
    }

    validate_array($package_name_real)

    package { $package_name_real:
      ensure => $package_ensure,
    }

  }

}

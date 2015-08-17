# == Class: logaggregation
#
# Module to manage the EIS Log Aggregation client
#
class logaggregation(
  $manage_packages           = true,
  $manage_rsyslog_fragment   = false,
  $package_ensure            = 'installed',
  $package_name              = 'USE_DEFAULTS',
  $rsyslog_fragment_epilogue = undef,
  $rsyslog_fragment_file     = 'logaggregation',
  $rsyslog_fragment_preamble = undef,
  $rsyslog_insight_server    = undef,
  $rsyslog_insight_port      = 514,
  $rsyslog_selector          = '*.*',
) {

  # variable type validation
  validate_bool($manage_packages)
  validate_bool($manage_rsyslog_fragment)

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

  if $manage_rsyslog_fragment == true {
    include rsyslog

    # variable type validation
    if is_domain_name($rsyslog_insight_server)  == false { fail('logaggregation::rsyslog_insight_server is not a domain name.') }
    validate_integer($rsyslog_insight_port, 65535, 1)
    if is_string($rsyslog_fragment_epilogue) == false { fail('logaggregation::rsyslog_fragment_epilogue is not a string.') }
    if is_string($rsyslog_fragment_file)     == false { fail('logaggregation::rsyslog_fragment_file is not a string.') }
    if is_string($rsyslog_fragment_preamble) == false { fail('logaggregation::rsyslog_fragment_preamble is not a string.') }
    if is_string($rsyslog_selector)          == false { fail('logaggregation::rsyslog_selector is not a string.') }

    # add line break to preamble and epilogue
    if $rsyslog_fragment_preamble != undef {
      $rsyslog_fragment_preamble_real = "${rsyslog_fragment_preamble}\n"
    }
    if $rsyslog_fragment_epilogue != undef {
      $rsyslog_fragment_epilogue_real = "${rsyslog_fragment_epilogue}\n"
    }

    $_rsyslog_forward          = "${rsyslog_selector} @${rsyslog_insight_server}:${rsyslog_insight_port}\n"
    $_rsyslog_fragment_content = "${rsyslog_fragment_preamble_real}${_rsyslog_forward}${rsyslog_fragment_epilogue_real}"
    $_rsyslog_fragment_hash    = { 'content' => $_rsyslog_fragment_content }

    create_resources('rsyslog::fragment', { "${rsyslog_fragment_file}" => $_rsyslog_fragment_hash } )
  }

}

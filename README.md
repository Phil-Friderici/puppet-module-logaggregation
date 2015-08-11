# puppet-module-logaggreation #
===

Puppet module to manage client packages for EIS Log aggregation

===

# Compatability #

This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and Puppet v4 with Ruby versions 1.8.7,
1.9.3, 2.0.0 and 2.1.0.

This module can be used on all OSfamilies with packages available.

If you want this module to manage the rsyslog fragment file for you, please
check ghoneycutt/rsyslog for compatibility details of supported OSfamilies.

===

# Parameters #

manage_rsyslog_fragment
-----------------------
Boolean to trigger management of rsyslog fragment support.

- *Default*: false

package_ensure
--------------
String for the ensure attribute for the packages.

- *Default*: 'installed'

package_name
------------
String or Array of packages to manage.

- *Default*: '[ 'EISlogging', 'EISloggingNFS', ]'

rsyslog_fragment_epilogue
-------------------------
String with text to be inserted at the end of the fragment file.

- *Default*: undef

rsyslog_fragment_file
---------------------
String with the name for the fragment file.

- *Default*: 'logaggregation'

rsyslog_fragment_preamble
-------------------------
String with text to be inserted at the beginning of the fragment file.

- *Default*: undef

rsyslog_insight_server
----------------------
String with the name of the Insight server to be used in the fragment file.

- *Default*: undef

rsyslog_insight_port
--------------------
Integer with the port of the Insight server to be used in the fragment file.

- *Default*: 514

rsyslog_selector
----------------
String with the selector to be used in the fragment file.

- *Default*: '*.*'

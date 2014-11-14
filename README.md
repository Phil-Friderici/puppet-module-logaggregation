# puppet-module-logaggreation
===

Puppet module to manage client packages for EIS Log aggregation

===

# Parameters
------------

package_name
------------
String or Array of packages to manage.

- *Default*: '[ 'EISlogging', 'EISloggingNFS', ]'

package_ensure
--------------
Ensure attribute for the packages.

- *Default*: 'installed'

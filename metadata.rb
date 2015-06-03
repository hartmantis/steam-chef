# Encoding: UTF-8
#
# rubocop:disable SingleSpaceBeforeFirstArg
name             'steam'
maintainer       'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license          'apache2'
description      'Installs/Configures Steam'
long_description 'Installs/Configures Steam'
version          '0.1.1'

depends          'dmg', '~> 2.2'
depends          'windows', '~> 1.37'
depends          'apt', '~> 2.7'

supports         'mac_os_x'
supports         'windows'
supports         'ubuntu'
supports         'debian', '>= 8.0'
# rubocop:enable SingleSpaceBeforeFirstArg

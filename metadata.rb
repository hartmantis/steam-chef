# Encoding: UTF-8

name             'steam'
maintainer       'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license          'apache2'
description      'Installs/Configures Steam'
long_description 'Installs/Configures Steam'
version          '2.2.3'

depends          'dmg', '~> 3.0'    # 3.1 available
depends          'windows', '~> 2.0.2' # 2.1.1 available
depends          'apt'

supports         'mac_os_x'
supports         'windows'
supports         'ubuntu'
supports         'debian', '>= 8.0'

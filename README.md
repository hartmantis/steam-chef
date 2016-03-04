Steam Cookbook
==============
[![Cookbook Version](https://img.shields.io/cookbook/v/steam.svg)][cookbook]
[![Linux Build Status](https://img.shields.io/circleci/project/RoboticCheese/steam-chef.svg)][circle]
[![OS X Build Status](https://img.shields.io/travis/RoboticCheese/steam-chef.svg)][travis]
[![Windows Build Status](https://img.shields.io/appveyor/ci/RoboticCheese/steam-chef.svg)][appveyor]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/steam-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/steam-chef.svg)][coveralls]

[cookbook]: https://supermarket.chef.io/cookbooks/steam
[circle]: https://circleci.com/gh/RoboticCheese/steam-chef
[travis]: https://travis-ci.org/RoboticCheese/steam-chef
[appveyor]: https://ci.appveyor.com/project/RoboticCheese/steam-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/steam-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/steam-chef

A Chef cookbook for installing Steam.

Requirements
============

This cookbook currently supports each of Steam's platforms: OS X, Windows, and
Ubuntu/Debian.

As of v2.0.0, it requires either Chef 12.5 or the
[compat_resource](https://supermarket.chef.io/cookbooks/compat_resource)
cookbook.

Usage
=====

Either add the default recipe to your run_list or implement the resource
directly in a recipe of your own.

Recipes
=======

***default***

Installs Steam.

Resources
=========

***steam_app***

A parent resource for managing the Steam app that all platform-specific
resources inherit from.

Syntax:

    steam_app 'default' do
        action :install
    end

Actions:

| Action     | Description     |
|------------|-----------------|
| `:install` | Install Steam   |
| `:remove`  | Uninstall Steam |

Attributes:

| Attribute  | Default    | Description          |
|------------|------------|----------------------|
| action     | `:install` | Action(s) to perform |

***steam_app_debian***

A Ubuntu/Debian implementation of the `steam_app` resource.

***steam_app_mac_os_x***

An OS X implementation of the `steam_app` resource.

***steam_app_windows***

A Windows implementation of the `steam_app` resource.

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <j@p4nt5.com>

Copyright 2015-2016, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

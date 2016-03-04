# Encoding: UTF-8
#
# Cookbook Name:: steam
# Library:: resource_steam_app_mac_os_x
#
# Copyright 2015-2016, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'
require_relative 'resource_steam_app'

class Chef
  class Resource
    # A custom resource for Steam for OS X.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class SteamAppMacOsX < SteamApp
      include Chef::Mixin::ShellOut

      URL ||= 'https://steamcdn-a.akamaihd.net/client/installer/steam.dmg'
              .freeze
      PATH ||= '/Applications/Steam.app'.freeze

      provides :steam_app, platform_family: 'mac_os_x'

      #
      # Use a dmg_package resource to download and install the package. The
      # dmg_resource creates an inline remote_file, so this is all that's
      # needed.
      #
      action :install do
        download_path = ::File.join(Chef::Config[:file_cache_path],
                                    ::File.basename(URL))
        remote_file download_path do
          source URL
          not_if { ::File.exist?(PATH) }
        end
        execute "echo Y | PAGER=true hdiutil attach '#{download_path}'" do
          not_if "hdiutil info | grep -q 'image-path.*#{download_path}'"
          not_if { ::File.exist?(PATH) }
        end
        execute 'rsync -a /Volumes/Steam/Steam.app /Applications/' do
          not_if { ::File.exist?(PATH) }
        end
        execute 'hdiutil detach /Volumes/Steam' do
          only_if "hdiutil info | grep -q 'image-path.*#{download_path}'"
        end
      end

      #
      # Clean up the steam app, support, and log directories.
      #
      action :remove do
        [
          PATH,
          ::File.expand_path('~/Library/Application Support/Steam'),
          ::File.expand_path('~/Library/Logs/Steam')
        ].each do |d|
          directory d do
            recursive true
            action :delete
          end
        end
      end
    end
  end
end

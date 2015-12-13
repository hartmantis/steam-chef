# Encoding: UTF-8
#
# Cookbook Name:: steam
# Library:: provider_steam_app_mac_os_x
#
# Copyright 2015 Jonathan Hartman
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
require 'chef/provider/lwrp_base'
require_relative 'provider_steam_app'

class Chef
  class Provider
    class SteamApp < Provider::LWRPBase
      # An provider for Steam on Mac OS X.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class MacOsX < SteamApp
        include Chef::Mixin::ShellOut

        URL ||= 'https://steamcdn-a.akamaihd.net/client/installer/steam.dmg'
        PATH ||= '/Applications/Steam.app'

        provides :steam_app, platform_family: 'mac_os_x'

        private

        #
        # Use a dmg_package resource to download and install the package. The
        # dmg_resource creates an inline remote_file, so this is all that's
        # needed.
        #
        # (see SteamApp#install!)
        #
        def install!
          remote_file download_path do
            source URL
            not_if { ::File.exist?(PATH) }
          end
          attach_dmg
          execute 'rsync -a /Volumes/Steam/Steam.app /Applications/' do
            not_if { ::File.exist?(PATH) }
          end
          detach_dmg
        end

        #
        # (see SteamApp#remove!)
        #
        def remove!
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

        #
        # Use an execute resource to attach the Steam .dmg file.
        #
        def attach_dmg
          path = download_path
          execute "echo Y | PAGER=true hdiutil attach '#{path}'" do
            not_if "hdiutil info | grep -q 'image-path.*#{path}'"
            not_if { ::File.exist?(PATH) }
          end
        end

        #
        # Use an execute resource to detach the Steam .dmg file.
        #
        def detach_dmg
          path = download_path
          execute 'hdiutil detach /Volumes/Steam' do
            only_if "hdiutil info | grep -q 'image-path.*#{path}'"
          end
        end

        #
        # Construct a download path within Chef's cache dir.
        #
        # @return [String] a local .dmg download path
        #
        def download_path
          ::File.join(Chef::Config[:file_cache_path], ::File.basename(URL))
        end
      end
    end
  end
end

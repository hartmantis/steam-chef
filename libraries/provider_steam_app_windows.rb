# Encoding: UTF-8
#
# Cookbook Name:: steam
# Library:: provider_steam_app_windows
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

require 'chef/provider/lwrp_base'
require_relative 'provider_steam_app'

class Chef
  class Provider
    class SteamApp < Provider::LWRPBase
      # An provider for Steam on Windows.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Windows < SteamApp
        URL ||= 'https://steamcdn-a.akamaihd.net/client/installer/' \
                'SteamSetup.exe'
        PATH ||= ::File.expand_path('/Program Files (x86)/Steam')

        private

        #
        # Download and install the remote package.
        #
        # (see SteamApp#install!)
        #
        def install!
          download_package
          install_package
        end

        #
        # Use a windows_package resource to uninstall Steam.
        #
        # (see SteamApp#remove!)
        #
        def remove!
          windows_package 'Steam' do
            action :remove
          end
        end

        #
        # Use a windows_package resource to install the .exe file.
        #
        def install_package
          s = download_path
          windows_package 'Steam' do
            source s
            installer_type :nsis
            action :install
          end
        end

        #
        # Use a remote_file resource to download the .exe file to Chef's cache
        # dir.
        #
        def download_package
          remote_file download_path do
            source URL
            action :create
            only_if { !::File.exist?(PATH) }
          end
        end

        #
        # Construct a download destination under Chef's cache dir.
        #
        # @return [String]
        #
        def download_path
          ::File.join(Chef::Config[:file_cache_path], ::File.basename(URL))
        end
      end
    end
  end
end

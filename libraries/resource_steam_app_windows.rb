# Encoding: UTF-8
#
# Cookbook Name:: steam
# Library:: resource_steam_app_windows
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

require_relative 'resource_steam_app'

class Chef
  class Resource
    # A custom resource for Steam for Windows
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class SteamAppWindows < SteamApp
      URL ||= 'https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe'
              .freeze
      PATH ||= ::File.expand_path('/Program Files (x86)/Steam').freeze

      provides :steam_app, platform_family: 'windows'

      #
      # Download and install the Steam Windows package.
      #
      action :install do
        download_path = ::File.join(Chef::Config[:file_cache_path],
                                    ::File.basename(URL))
        remote_file download_path do
          source URL
          action :create
          only_if { !::File.exist?(PATH) }
        end
        windows_package 'Steam' do
          source download_path
          installer_type :nsis
          action :install
        end
      end

      #
      # Use a windows_package resource to uninstall Steam.
      #
      action :remove do
        windows_package 'Steam' do
          action :remove
        end
      end
    end
  end
end

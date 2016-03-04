# Encoding: UTF-8
#
# Cookbook Name:: steam
# Library:: resource_steam_app_debian
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

require 'chef/dsl/include_recipe'
require_relative 'resource_steam_app'

class Chef
  class Resource
    # A Chef resource for Steam for Ubuntu/Debian.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class SteamAppDebian < SteamApp
      URL ||= 'https://steamcdn-a.akamaihd.net/client/installer/steam.deb'
              .freeze
      PATH ||= '/usr/bin/steam'.freeze

      include Chef::DSL::IncludeRecipe

      provides :steam_app, platform_family: 'debian'

      #
      # Download the Steam package, and install it.
      #
      # Ensure the steam package's dependencies are satisfied since we're
      # installing a .deb directly with dpkg. The package depends on one of
      # xterm, gnome-terminal, konsole, so only install xterm if neither of
      # the others is present.
      #
      # TODO: The hardcoded package list is pretty ugly. Should either pull
      # dependencies from the package file at runtime or wait for the APT
      # repo maintainers to fix the bug that prevents us from using that
      # (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=772598)
      #
      #
      action :install do
        include_recipe 'apt'
        %w(python libc6 python-apt xz-utils curl zenity).each do |p|
          package p do
            action :install
          end
        end
        package 'xterm' do
          action :install
          not_if 'dpkg -s gnome-terminal || dpkg -s konsole'
        end
        download_path = ::File.join(Chef::Config[:file_cache_path],
                                    ::File.basename(URL))
        remote_file download_path do
          source URL
          only_if { !::File.exist?(PATH) }
        end
        dpkg_package 'steam-launcher' do
          source download_path
        end
      end

      #
      # Use a dpkg_package resource to uninstall Steam.
      #
      action :remove do
        package 'steam-launcher' do
          action :remove
        end
      end
    end
  end
end

# Encoding: UTF-8
#
# Cookbook Name:: steam
# Library:: provider_steam_app_debian
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
require 'chef/dsl/include_recipe'
require_relative 'provider_steam_app'

class Chef
  class Provider
    class SteamApp < Provider::LWRPBase
      # An provider for Steam on Ubuntu/Debian.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Debian < SteamApp
        include Chef::DSL::IncludeRecipe

        # No URL or PATH--everything is handled by APT

        private

        #
        # Set up Steam's APT repository and install their package
        #
        # (see SteamApp#install!)
        #
        def install!
          add_repo
          apt_package 'steam' do
            response_file 'steam.seed'
            action :install
          end
        end

        #
        # Use an apt_package resource to uninstall Steam.
        #
        # (see SteamApp#remove!)
        #
        def remove!
          apt_package 'steam' do
            action :remove
          end
        end

        #
        # Configure Steam's APT repository, making sure APT's cache is
        # updated as well.
        #
        def add_repo
          include_recipe 'apt'
          apt_repository 'steam' do
            uri 'http://repo.steampowered.com/steam'
            components %w(precise steam)
            key 'B05498B7'
            keyserver 'keyserver.ubuntu.com'
            action :add
          end
        end
      end
    end
  end
end

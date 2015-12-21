require_relative '../../../spec_helper'

describe 'resource_steam_app::ubuntu::14_04' do
  let(:source) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'steam_app',
      platform: 'ubuntu',
      version: '14.04'
    )
  end
  let(:converge) { runner.converge("steam_app_test::#{action}") }

  context 'the default action (:install)' do
    let(:action) { :default }
    let(:term_installed?) { nil }

    before(:each) do
      stub_command('dpkg -s gnome-terminal || dpkg -s konsole')
        .and_return(term_installed?)
    end

    shared_examples_for 'any term installed status' do
      it 'installs the steam_app resource' do
        expect(chef_run).to install_steam_app('default')
      end

      it 'ensures the APT cache is up to date' do
        expect(chef_run).to include_recipe('apt')
      end

      %w(python libc6 python-apt xz-utils curl zenity).each do |p|
        it "installs the #{p} package" do
          expect(chef_run).to install_package(p)
        end
      end

      it 'downloads the remote package file' do
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/steam.deb"
        ).with(source: 'https://steamcdn-a.akamaihd.net/client/installer/' \
                       'steam.deb')
      end

      it 'installs the package file' do
        expect(chef_run).to install_dpkg_package('steam-launcher').with(
          source: "#{Chef::Config[:file_cache_path]}/steam.deb"
        )
      end
    end

    context 'term not installed' do
      let(:term_installed?) { false }
      cached(:chef_run) { converge }

      it_behaves_like 'any term installed status'

      it 'installs xterm' do
        expect(chef_run).to install_package('xterm')
      end
    end

    context 'term already installed' do
      let(:term_installed?) { true }
      cached(:chef_run) { converge }

      it_behaves_like 'any term installed status'

      it 'does not install xterm' do
        expect(chef_run).to_not install_package('xterm')
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }
    cached(:chef_run) { converge }

    it 'removes the steam_app resource' do
      expect(chef_run).to remove_steam_app('default')
    end

    it 'removes the steam-launcher package' do
      expect(chef_run).to remove_package('steam-launcher')
    end
  end
end

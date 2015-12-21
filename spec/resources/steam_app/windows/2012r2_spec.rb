require_relative '../../../spec_helper'

describe 'resource_steam_app::windows::2012r2' do
  let(:source) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'steam_app',
      platform: 'windows',
      version: '2012R2'
    )
  end
  let(:converge) { runner.converge("steam_app_test::#{action}") }

  context 'the default action (:install)' do
    let(:action) { :default }
    let(:installed?) { nil }

    before(:each) do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?)
        .with(File.expand_path('/Program Files (x86)/Steam'))
        .and_return(installed?)
    end

    shared_examples_for 'any installed status' do
      it 'installs the steam_app resource' do
        expect(chef_run).to install_steam_app('default')
      end
    end

    context 'not already installed' do
      let(:installed?) { false }
      cached(:chef_run) { converge }

      it_behaves_like 'any installed status'

      it 'downloads the remote package file' do
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/SteamSetup.exe"
        ).with(source: 'https://steamcdn-a.akamaihd.net/client/installer/' \
                       'SteamSetup.exe')
      end

      it 'installs the package file' do
        expect(chef_run).to install_windows_package('Steam').with(
          source: "#{Chef::Config[:file_cache_path]}/SteamSetup.exe",
          installer_type: :nsis
        )
      end
    end

    context 'already installed' do
      let(:installed?) { true }
      cached(:chef_run) { converge }

      it_behaves_like 'any installed status'

      it 'does not download the remote package file' do
        expect(chef_run).to_not create_remote_file(
          "#{Chef::Config[:file_cache_path]}/SteamSetup.exe"
        )
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }
    cached(:chef_run) { converge }

    it 'removes the steam_app resource' do
      expect(chef_run).to remove_steam_app('default')
    end

    it 'removes the steam package' do
      expect(chef_run).to remove_windows_package('Steam')
    end
  end
end

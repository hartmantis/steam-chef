require_relative '../../../spec_helper'

describe 'resource_steam_app::mac_os_x::10_10' do
  let(:source) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'steam_app',
      platform: 'mac_os_x',
      version: '10.10'
    )
  end
  let(:converge) { runner.converge("steam_app_test::#{action}") }

  context 'the default action (:install)' do
    let(:action) { :default }
    let(:mounted?) { nil }
    let(:installed?) { nil }

    before(:each) do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?)
        .with('/Applications/Steam.app').and_return(installed?)
      stub_command(%r{hdiutil info \| grep -q 'image-path\.\*.*/steam.dmg'})
        .and_return(mounted?)
    end

    shared_examples_for 'any installed status' do
      it 'installs the steam_app resource' do
        expect(chef_run).to install_steam_app('default')
      end
    end

    context 'not already installed' do
      let(:installed?) { false }

      context 'volume not mounted' do
        let(:mounted?) { false }
        cached(:chef_run) { converge }

        it_behaves_like 'any installed status'

        it 'downloads the remote file' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/steam.dmg"
          ).with(
            source: 'https://steamcdn-a.akamaihd.net/client/installer/steam.dmg'
          )
        end

        it 'attaches the .dmg' do
          expect(chef_run).to run_execute(
            "echo Y | PAGER=true hdiutil attach '" \
            "#{Chef::Config[:file_cache_path]}/steam.dmg'"
          )
        end

        it 'rsyncs the .dmg contents' do
          expect(chef_run).to run_execute(
            'rsync -a /Volumes/Steam/Steam.app /Applications/'
          )
        end

        it 'does not detach the .dmg' do
          expect(chef_run).to_not run_execute('hdiutil detach /Volumes/Steam')
        end
      end

      context 'volume already mounted' do
        let(:mounted?) { true }
        cached(:chef_run) { converge }

        it_behaves_like 'any installed status'

        it 'downloads the remote file' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/steam.dmg"
          ).with(
            source: 'https://steamcdn-a.akamaihd.net/client/installer/steam.dmg'
          )
        end

        it 'does not attach the .dmg' do
          expect(chef_run).to_not run_execute(
            "echo Y | PAGER=true hdiutil attach '" \
            "#{Chef::Config[:file_cache_path]}/steam.dmg'"
          )
        end

        it 'rsyncs the .dmg contents' do
          expect(chef_run).to run_execute(
            'rsync -a /Volumes/Steam/Steam.app /Applications/'
          )
        end

        it 'detaches the .dmg' do
          expect(chef_run).to run_execute('hdiutil detach /Volumes/Steam')
        end
      end
    end

    context 'already installed' do
      let(:installed?) { true }
      cached(:chef_run) { converge }

      it_behaves_like 'any installed status'

      it 'does not download the remote file' do
        expect(chef_run).to_not create_remote_file(
          "#{Chef::Config[:file_cache_path]}/steam.dmg"
        )
      end

      it 'does not attach the .dmg' do
        expect(chef_run).to_not run_execute(
          "echo Y | PAGER=true hdiutil attach '" \
          "#{Chef::Config[:file_cache_path]}/steam.dmg'"
        )
      end

      it 'does not rsync the .dmg contents' do
        expect(chef_run).to_not run_execute(
          'rsync -a /Volumes/Steam/Steam.app /Applications/'
        )
      end

      it 'does not detach the .dmg' do
        expect(chef_run).to_not run_execute('hdiutil detach /Volumes/Steam')
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }
    cached(:chef_run) { converge }

    it 'removes the steam_app resource' do
      expect(chef_run).to remove_steam_app('default')
    end

    it 'deletes the main application dir' do
      d = '/Applications/Steam.app'
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end

    it 'deletes the application support dir' do
      d = File.expand_path('~/Library/Application Support/Steam')
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end

    it 'deletes the log dir' do
      d = File.expand_path('~/Library/Logs/Steam')
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end
  end
end

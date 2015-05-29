# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_steam_app_windows'

describe Chef::Provider::SteamApp::Windows do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::SteamApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#install!' do
    it 'downloads and installs the package' do
      p = provider
      expect(p).to receive(:download_package)
      expect(p).to receive(:install_package)
      p.send(:install!)
    end
  end

  describe '#remove!' do
    it 'uses a windows_package to uninstall the package' do
      p = provider
      expect(p).to receive(:windows_package).with('Steam').and_yield
      expect(p).to receive(:action).with(:remove)
      p.send(:remove!)
    end
  end

  describe '#install_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/SteamSetup.exe')
    end

    it 'uses a windows_package to install the package' do
      p = provider
      expect(p).to receive(:windows_package).with('Steam').and_yield
      expect(p).to receive(:source).with('/tmp/SteamSetup.exe')
      expect(p).to receive(:installer_type).with(:nsis)
      expect(p).to receive(:action).with(:install)
      p.send(:install_package)
    end
  end

  describe '#download_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/SteamSetup.exe')
    end

    it 'uses a remote_file to download the package' do
      p = provider
      expect(p).to receive(:remote_file).with('/tmp/SteamSetup.exe').and_yield
      expect(p).to receive(:source).with(described_class::URL)
      expect(p).to receive(:action).with(:create)
      expect(p).to receive(:only_if).and_yield
      expect(File).to receive(:exist?).with(described_class::PATH)
      p.send(:download_package)
    end
  end

  describe '#download_path' do
    it 'returns a path under the Chef cache dir' do
      expected = "#{Chef::Config[:file_cache_path]}/SteamSetup.exe"
      expect(provider.send(:download_path)).to eq(expected)
    end
  end
end

# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_steam_app_debian'

describe Chef::Provider::SteamApp::Debian do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::SteamApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#install!' do
    it 'installs dependencies, downloads and installs the package' do
      p = provider
      expect(p).to receive(:resolve_dependencies)
      expect(p).to receive(:download_package)
      expect(p).to receive(:install_package)
      p.send(:install!)
    end
  end

  describe '#remove!' do
    it 'uses a dpkg_package to uninstall the package' do
      p = provider
      expect(p).to receive(:dpkg_package).with('steam-launcher').and_yield
      expect(p).to receive(:action).with(:remove)
      p.send(:remove!)
    end
  end

  describe '#install_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/steam.deb')
    end

    it 'uses a dpkg_package to install the package' do
      p = provider
      expect(p).to receive(:dpkg_package).with('steam-launcher').and_yield
      expect(p).to receive(:source).with('/tmp/steam.deb')
      expect(p).to receive(:action).with(:install)
      p.send(:install_package)
    end
  end

  describe '#download_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/steam.deb')
    end

    it 'uses a remote_file to download the package' do
      p = provider
      expect(p).to receive(:remote_file).with('/tmp/steam.deb').and_yield
      expect(p).to receive(:source).with(described_class::URL)
      expect(p).to receive(:action).with(:create)
      expect(p).to receive(:only_if).and_yield
      expect(File).to receive(:exist?).with(described_class::PATH)
      p.send(:download_package)
    end
  end

  describe '#download_path' do
    it 'returns a path under the Chef cache dir' do
      expected = "#{Chef::Config[:file_cache_path]}/steam.deb"
      expect(provider.send(:download_path)).to eq(expected)
    end
  end

  describe '#resolve_dependencies' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:include_recipe)
      allow_any_instance_of(described_class).to receive(:package)
    end

    it 'ensures the APT cache is up to date' do
      p = provider
      expect(p).to receive(:include_recipe).with('apt')
      p.send(:resolve_dependencies)
    end

    it 'installs all the hard requirements and, conditonally, xterm' do
      p = provider
      %w(python libc6 python-apt xz-utils curl zenity).each do |pkg|
        expect(p).to receive(:package).with(pkg).and_yield
        expect(p).to receive(:action).with(:install)
      end
      expect(p).to receive(:package).with('xterm').and_yield
      expect(p).to receive(:action).with(:install)
      expect(p).to receive(:not_if)
        .with('dpkg -s gnome-terminal || dpkg -s konsole')
      p.send(:resolve_dependencies)
    end
  end
end

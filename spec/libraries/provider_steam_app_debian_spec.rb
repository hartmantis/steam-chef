# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_steam_app_debian'

describe Chef::Provider::SteamApp::Debian do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::SteamApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#install!' do
    it 'adds the repo and installs the package' do
      p = provider
      expect(p).to receive(:add_repo)
      expect(p).to receive(:apt_package).with('steam').and_yield
      expect(p).to receive(:response_file).with('steam.seed')
      expect(p).to receive(:action).with(:install)
      p.send(:install!)
    end
  end

  describe '#remove!' do
    it 'uses an apt_package to uninstall the package' do
      p = provider
      expect(p).to receive(:apt_package).with('steam').and_yield
      expect(p).to receive(:action).with(:remove)
      p.send(:remove!)
    end
  end

  describe '#add_repo' do
    it 'updates the APT cache and adds the repo' do
      p = provider
      expect(p).to receive(:include_recipe).with('apt')
      expect(p).to receive(:apt_repository).with('steam').and_yield
      expect(p).to receive(:uri).with('http://repo.steampowered.com/steam')
      expect(p).to receive(:components).with(%w(precise steam))
      expect(p).to receive(:key).with('B05498B7')
      expect(p).to receive(:keyserver).with('keyserver.ubuntu.com')
      expect(p).to receive(:action).with(:add)
      p.send(:add_repo)
    end
  end
end

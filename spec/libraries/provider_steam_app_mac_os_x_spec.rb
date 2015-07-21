# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_steam_app_mac_os_x'

describe Chef::Provider::SteamApp::MacOsX do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::SteamApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end
  end

  describe '#install!' do
    it 'uses a dmg_package resource to install Steam' do
      p = provider
      expect(p).to receive(:dmg_package).with('Steam').and_yield
      expect(p).to receive(:source).with(described_class::URL)
      expect(p).to receive(:accept_eula).with(true)
      expect(p).to receive(:action).with(:install)
      p.send(:install!)
    end
  end

  describe '#remove!' do
    it 'deletes the app, support, and log directories' do
      dirs = ['/Applications/Steam.app',
              File.expand_path('~/Library/Application Support/Steam'),
              File.expand_path('~/Library/Logs/Steam')]
      p = provider
      dirs.each do |d|
        expect(p).to receive(:directory).with(d).and_yield
        expect(p).to receive(:recursive).with(true)
        expect(p).to receive(:action).with(:delete)
      end
      p.send(:remove!)
    end
  end
end

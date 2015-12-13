# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_steam_app_mac_os_x'

describe Chef::Provider::SteamApp::MacOsX do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::SteamApp.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

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
    before(:each) do
      %i(remote_file attach_dmg execute detach_dmg).each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
    end

    it 'downloads the .dmg file' do
      p = provider
      expect(p).to receive(:remote_file)
        .with("#{Chef::Config[:file_cache_path]}/steam.dmg").and_yield
      expect(p).to receive(:source).with(described_class::URL)
      expect(p).to receive(:not_if).and_yield
      expect(File).to receive(:exist?).with(described_class::PATH)
      p.send(:install!)
    end

    it 'attaches the .dmg file' do
      p = provider
      expect(p).to receive(:attach_dmg)
      p.send(:install!)
    end

    it 'rsyncs the .dmg contents' do
      p = provider
      expect(p).to receive(:execute)
        .with('rsync -a /Volumes/Steam/Steam.app /Applications/').and_yield
      expect(p).to receive(:not_if).and_yield
      expect(File).to receive(:exist?).with(described_class::PATH)
      p.send(:install!)
    end

    it 'detaches the .dmg file' do
      p = provider
      expect(p).to receive(:detach_dmg)
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

  describe '#attach_dmg' do
    it 'attaches the .dmg file' do
      p = provider
      expect(p).to receive(:execute).with(
        "echo Y | PAGER=true hdiutil attach '" \
        "#{Chef::Config[:file_cache_path]}/steam.dmg'"
      ).and_yield
      expect(p).to receive(:not_if).with(
        "hdiutil info | grep -q 'image-path.*" \
        "#{Chef::Config[:file_cache_path]}/steam.dmg'"
      )
      expect(p).to receive(:not_if).and_yield
      expect(File).to receive(:exist?).with(described_class::PATH)
      p.send(:attach_dmg)
    end
  end

  describe '#detach_dmg' do
    it 'detaches the .dmg file' do
      p = provider
      expect(p).to receive(:execute).with('hdiutil detach /Volumes/Steam')
        .and_yield
      expect(p).to receive(:only_if).with(
        "hdiutil info | grep -q 'image-path.*" \
        "#{Chef::Config[:file_cache_path]}/steam.dmg'"
      )
      p.send(:detach_dmg)
    end
  end

  describe '#download_path' do
    it 'returns a path in the Chef cache dir' do
      expect(provider.send(:download_path)).to eq(
        "#{Chef::Config[:file_cache_path]}/steam.dmg"
      )
    end
  end
end

# Encoding: UTF-8

require_relative '../spec_helper'

describe 'steam::default' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs Steam' do
    expect(chef_run).to install_steam_app('default')
  end
end

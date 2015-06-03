# Encoding: UTF-8

require_relative '../spec_helper'

describe 'steam::app' do
  describe file('/Applications/Steam.app'), if: os[:family] == 'darwin' do
    it 'exists' do
      expect(subject).to be_directory
    end
  end

  describe package('Steam'), if: os[:family] == 'windows' do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  describe package('steam-launcher'),
           if: %w(ubuntu debian).include?(os[:family]) do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end
end

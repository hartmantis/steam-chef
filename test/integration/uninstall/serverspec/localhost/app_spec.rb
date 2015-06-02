# Encoding: UTF-8

require_relative '../spec_helper'

describe 'steam::app' do
  describe file('/Applications/Steam.app'), if: os[:family] == 'darwin' do
    it 'does not exist' do
      expect(subject).not_to be_directory
    end
  end

  describe package('Steam'), if: os[:family] == 'windows' do
    it 'is not installed' do
      expect(subject).not_to be_installed
    end
  end

  describe package('steam-launcher'),
           if: %w(ubuntu debian).include?(os[:family]) do
    it 'is not installed' do
      expect(subject).not_to be_installed
    end
  end

  # Just in case, check both package names it might be going by
  describe package('steam'), if: %w(ubuntu debian).include?(os[:family]) do
    it 'is not installed' do
      expect(subject).not_to be_installed
    end
  end
end

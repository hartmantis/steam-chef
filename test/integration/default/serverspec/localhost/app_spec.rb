# Encoding: UTF-8

require_relative '../spec_helper'

describe 'steam::app' do
  describe file('/Applications/Steam.app'), if: os[:family] == 'darwin' do
    it 'exists' do
      expect(subject).to be_directory
    end
  end
end

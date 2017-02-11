require 'spec_helper'
describe 'pure' do
  context 'with default values for all parameters' do
    it { should contain_class('pure') }
  end
end

require 'spec_helper'
describe 'db2' do

  context 'with defaults for all parameters' do
    it { should contain_class('db2') }
  end
end

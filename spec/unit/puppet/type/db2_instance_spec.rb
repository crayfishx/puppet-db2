require 'spec_helper'

describe Puppet::Type.type(:db2_instance) do

  context 'parameters' do
    [
      :name,
      :install_root,
      :fence_user,
      :port,
      :auth,
      :type,
    ].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end
  end

  context 'validation' do
    it "must require an install root" do
      expect do
        described_class.new(
          :name => 'db2inst'
        ).to raise_error(/Must supply parameter install_root/)
      end
    end
  end

  context 'when declared with minimal params' do
  end
end


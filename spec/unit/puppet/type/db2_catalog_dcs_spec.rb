require 'spec_helper'

describe Puppet::Type.type(:db2_catalog_dcs) do

  context 'parameters' do
    [
      :instance,
      :install_root,
      :target,
      :ar_library,
      :params,
      :comment
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
          :name => 'db2inst',
          :instance => 'foo',
        ).to raise_error(/Must supply parameter install_root/)
      end
    end
    it "must require an instance" do
      expect do
        described_class.new(
          :name => 'db2inst',
          :install_root => 'foo',
        ).to raise_error(/Must supply parameter instance/)
      end
    end
  end

  context 'when declared with minimal params' do
  end
end

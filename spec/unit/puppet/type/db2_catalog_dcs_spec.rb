require 'spec_helper'

describe Puppet::Type.type(:db2_catalog_dcs) do

  context 'parameters' do
    [
      :instance,
      :install_root,
      :name,
    ].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end
  end

  context 'property' do
    [
      :target,
      :ar_library,
      :params,
      :comment
    ].each do |param|
      it "should have a #{param} property" do
        expect(described_class.attrtype(param)).to eq(:property)
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
    it "should compile" do
      expect do
        described_class.new(
          :name => 'db2inst',
          :install_root => 'foo',
          :instance => 'bar',
        ).not_to raise_error
      end
    end
  end

  describe "provider" do
    scenarios = [
      {
      :name => "With minimal configuration",
      :with => {}, 
      :expect => 'CATALOG DCS DATABASE db2db'
      },
      {
      :name => "With target",
      :with => {:target => 'db2target'}, 
      :expect => 'CATALOG DCS DATABASE db2db AS DB2TARGET'
      },
      {
      :name => "With application requestor",
      :with => {:target => 'db2target', :ar_library => 'arlib', :params => 'arparam'}, 
      :expect => 'CATALOG DCS DATABASE db2db AS DB2TARGET AR arlib PARMS \'"arparam"\''
      },
      {
      :name => "With comment",
      :with => {:target => 'db2target', :ar_library => 'arlib', :params => 'arparam', :comment => "dcs description"}, 
      :expect => 'CATALOG DCS DATABASE db2db AS DB2TARGET AR arlib PARMS \'"arparam"\' WITH \'"dcs description"\''
      },
    ]
    
    scenarios.each do |scenario|
      context scenario[:name] do
        let(:resource) {
          described_class.new(
            scenario[:with].merge({ :name => 'db2db', :instance => 'db2inst', :install_root => '/opt/ibm/db2/V11.1'})
          )
        }
        let(:provider) { resource.provider }

        it "should execute the correct db2 commands" do
          provider.expects(:exec_db2_command).with("/opt/ibm/db2/V11.1/bin/db2 #{scenario[:expect]}", { "DB2INSTANCE" => "db2inst" }, true)
          provider.expects(:exec_db2_command).with("/opt/ibm/db2/V11.1/bin/db2 terminate", { "DB2INSTANCE" => "db2inst" }, true)
          provider.create
        end
      end
    end

    context "destroying" do
      let(:resource) {
        described_class.new(
          :name => 'db2db',
          :ensure => 'absent',
          :install_root => '/opt/ibm/db2/V11.1',
          :instance   => 'db2inst'
         )
      }
      let(:provider) { resource.provider }
      it "should uncatalog the node" do
        provider.expects(:exec_db2_command).with("/opt/ibm/db2/V11.1/bin/db2 UNCATALOG DCS DATABASE db2db", { "DB2INSTANCE" => "db2inst" }, true)
        provider.expects(:exec_db2_command).with("/opt/ibm/db2/V11.1/bin/db2 terminate", { "DB2INSTANCE" => "db2inst" }, true)
        provider.destroy
      end
    end

  end

end

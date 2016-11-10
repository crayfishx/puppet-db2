require 'spec_helper'

describe Puppet::Type.type(:db2_catalog_database) do

  describe "type" do

    context 'parameters' do
      [
        :instance,
        :install_root,
        :as_alias,
        :db_name,
        :path,
        :node,
        :authentication,
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

      it "should have as_alias as its namevar" do
        expect(described_class.key_attributes).to eq([:as_alias])
      end
    end

    context 'when declared with minimal params' do
    end
  end

  describe "provider" do

    scenarios = [
      {
        :name   => "With a node",
        :with   => { :db_name => 'db2db', :as_alias => 'db2alias', :node => 'db2node', :authentication => 'SERVER', :comment => 'DB2 DB' },
        :expect => 'CATALOG DATABASE db2db AS db2alias AT NODE db2node AUTHENTICATION SERVER WITH "DB2 DB"'
      },
    ]
    scenarios.each do |scenario|
      context scenario[:name] do
        let(:resource) {
          described_class.new(
            scenario[:with].merge({ :title => 'db2 entry', :instance => 'db2inst', :install_root => '/opt/ibm/db2/V11.1'})
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
  end
end

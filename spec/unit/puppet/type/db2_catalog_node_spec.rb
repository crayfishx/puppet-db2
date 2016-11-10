require 'spec_helper'
require 'puppet/parameter/boolean'

describe Puppet::Type.type(:db2_catalog_node) do


  describe "type" do

    context 'parameters' do
      [
        :instance,
        :install_root,
        :type,
        :to_instance,
        :admin,
        :remote,
        :server,
        :security,
        :remote_instance,
        :system,
        :ostype,
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
      it "must require a type" do
        expect do
          described_class.new(
            :name => 'db2inst',
            :install_root => 'foo',
            :instance => 'foo',
          ).to raise_error(/Must supply parameter type/)
        end
      end
    end

    context 'when declared with minimal params' do
      it "should compile" do
        expect do
          described_class.new(
            :name => 'db2node',
            :install_root => '/opt/ibm/db2/V11.1',
            :instance  => 'db2inst',
            :type  => 'tcpip',
          ).not_to raise_error
        end
      end
    end
  end

  describe "provider" do
    scenarios = [
      {
        :name   => "With minimal configuration",
        :with   => { :type => 'tcpip', :remote => 'db2remote', :server => 'db2server' },
        :expect => 'CATALOG TCPIP NODE db2node REMOTE db2remote SERVER db2server'
      },
      {
        :name   => "With admin",
        :with   => { :type => 'tcpip', :admin => true, :remote => 'db2remote' },
        :expect => 'CATALOG ADMIN TCPIP NODE db2node REMOTE db2remote'
      },
      {
        :name   => "With security socks",
        :with   => { :type => 'tcpip', :security => 'socks', :remote => 'db2remote', :server => 'db2server' },
        :expect => 'CATALOG TCPIP NODE db2node REMOTE db2remote SERVER db2server SECURITY SOCKS'
      },
      {
        :name   => "With remote instance",
        :with   => { :type => 'tcpip', :remote_instance => 'db2_remoteinst', :remote => 'db2remote', :server => 'db2server' },
        :expect => 'CATALOG TCPIP NODE db2node REMOTE db2remote SERVER db2server REMOTE_INSTANCE db2_remoteinst'
      },
      {
        :name   => "With system",
        :with   => { :type => 'tcpip', :system => 'db2system', :remote => 'db2remote', :server => 'db2server' },
        :expect => 'CATALOG TCPIP NODE db2node REMOTE db2remote SERVER db2server SYSTEM db2system'
      },
      {
        :name   => "With ostype",
        :with   => { :type => 'tcpip', :ostype => 'linux', :remote => 'db2remote', :server => 'db2server' },
        :expect => 'CATALOG TCPIP NODE db2node REMOTE db2remote SERVER db2server OSTYPE linux'
      },
      {
        :name   => "With comment",
        :with   => { :type => 'tcpip', :comment => 'test stuff', :remote => 'db2remote', :server => 'db2server' },
        :expect => 'CATALOG TCPIP NODE db2node REMOTE db2remote SERVER db2server WITH "test stuff"'
      },

      # Test LOCAL NODE
      {
        :name   => "With a local entry using minimal config",
        :with   => { :type => 'local' },
        :expect => 'CATALOG LOCAL NODE db2node'
      },
      {
        :name   => "With a local entry using system, ostype and to_instance",
        :with   => { :type => 'local', :comment => 'test stuff', :system => 'db2sys', :ostype => 'linux', :to_instance => 'db2toinst' },
        :expect => 'CATALOG LOCAL NODE db2node INSTANCE db2toinst SYSTEM db2sys OSTYPE linux WITH "test stuff"'
      },


    ]

    scenarios.each do |scenario|
      context scenario[:name] do
        let(:resource) {
          described_class.new(
            scenario[:with].merge({ :name => 'db2node', :instance => 'db2inst', :install_root => '/opt/ibm/db2/V11.1'})
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

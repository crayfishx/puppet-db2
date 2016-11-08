
require 'puppetlabs_spec_helper/module_spec_helper'


require 'spec_helper'

describe "db2::instance" do

  let(:title) { 'db2inst' }
  let(:facts) do
    {
    :operatingsystem => 'RedHat',
    :osfamily => 'RedHat'
    }
  end

  # Seem to be hitting https://github.com/rodjek/rspec-puppet/issues/256
  # Unresolved, but this workaround seems to fix it.
  let(:pre_condition) do
    "User { provider => 'useradd' }"
  end


  context "when declared with defaults" do
  let(:facts) do
    {
    :operatingsystem => 'RedHat',
    :osfamily => 'RedHat'
    }
  end
    let(:params) {{ :installation_root => '/opt/ibm/db2/V11.1' }}
    it do
      is_expected.to contain_user('db2inst').that_comes_before('Db2_instance[db2inst]')
    end
    it do
      is_expected.to contain_db2_instance('db2inst').with(
        :type => 'ese',
        :auth => 'server',
        :fence_user => nil,
      )
    end
  end
  context "when declared with fence user" do
    let(:params) {{ 
      :installation_root => '/opt/ibm/db2/V11.1',
      :fence_user => 'db2fence'
    }}
    it do
      is_expected.to contain_user('db2inst').that_comes_before('Db2_instance[db2inst]')
    end
    it do
      is_expected.to contain_user('db2fence').that_comes_before('Db2_instance[db2inst]')
    end
    it do
      is_expected.to contain_db2_instance('db2inst').with(
        :type => 'ese',
        :auth => 'server',
        :fence_user => 'db2fence'
      )
    end
  end
  context "when declaring user attributes" do
    let(:params) {{ 
      :installation_root => '/opt/ibm/db2/V11.1',
      :fence_user => 'db2fence',
      :instance_user_uid => '1001',
      :instance_user_gid => 'db2instg',
      :instance_user_home => '/db2/inst',
      :fence_user_uid => '1002',
      :fence_user_gid => 'db2fencg',
      :fence_user_home => '/db2/fence',
    }}
    it do
      is_expected.to contain_user('db2inst').with(
        :uid => '1001',
        :gid => 'db2instg',
        :home => '/db2/inst'
      )
    end
    it do
      is_expected.to contain_user('db2fence').with(
        :uid => '1002',
        :gid => 'db2fencg',
        :home => '/db2/fence',
      )
    end
  end

  context "when declaring with manage_instance_user falsified" do
    let(:params) {{ 
      :installation_root => '/opt/ibm/db2/V11.1',
      :fence_user => 'db2fence',
      :manage_instance_user => false,
    }}
    it do
      is_expected.not_to contain_user('db2inst')
    end
    it do
      is_expected.to contain_user('db2fence').that_comes_before('Db2_instance[db2inst]')
    end
    it do
      is_expected.to contain_db2_instance('db2inst').with(
        :type => 'ese',
        :auth => 'server',
        :fence_user => 'db2fence'
      )
    end
  end

  context "when declaring with manage_fence_user falsified" do
    let(:params) {{ 
      :installation_root => '/opt/ibm/db2/V11.1',
      :fence_user => 'db2fence',
      :manage_fence_user => false,
    }}
    it do
      is_expected.not_to contain_user('db2fence')
    end
    it do
      is_expected.to contain_user('db2inst').that_comes_before('Db2_instance[db2inst]')
    end
    it do
      is_expected.to contain_db2_instance('db2inst').with(
        :type => 'ese',
        :auth => 'server',
        :fence_user => 'db2fence'
      )
    end
  end

  context "when setting the installation type and auth options" do
    let(:params) {{ 
      :installation_root => '/opt/ibm/db2/V11.1',
      :fence_user => 'db2fence',
      :type       => 'standalone',
      :auth       => 'client'
    }}
    it do
      is_expected.to contain_db2_instance('db2inst').with(
        :type => 'standalone',
        :auth => 'client',
        :fence_user => 'db2fence'
      )
    end
  end

  context "when setting the port option" do
    let(:params) {{ 
      :installation_root => '/opt/ibm/db2/V11.1',
      :fence_user => 'db2fence',
      :type       => 'standalone',
      :auth       => 'client',
      :port       => 'db2port',
    }}
    it do
      is_expected.to contain_db2_instance('db2inst').with(
        :type => 'standalone',
        :auth => 'client',
        :fence_user => 'db2fence',
        :port => 'db2port'
      )
    end
  end

      
    


end




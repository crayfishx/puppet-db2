Puppet::Type.newtype(:db2_instance) do

  @doc = %q{
    The db2_instance type interacts with the db2 command to create a new
    instance.  Users and groups must already exist.  For setting up
    the required dependancies it's recommended to use the db2::instance
    defined resource type from the Puppet module
  }

  validate do
    [
      :install_root,
    ].each do |param|
      if self[param].nil?
        raise ArgumentError, "Must supply parameter #{param}"
      end
    end
  end

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:install_root) do
    desc "The path to the root of the DB2 installation (mandatory)"
  end

  newparam(:name, :namevar => true) do
    desc "The name of the instance (must match a pre-existing user)"
  end

  newparam(:fence_user) do
    desc "Specify a fence user to configure (must already exist if defined)"
  end

  newparam(:port) do
    desc "Specify the port name"
  end

  newparam(:auth) do
    desc "Specify the authentication type."
  end

  newparam(:type) do
    desc "Specify the type of instance (eg: ese, client)"
  end

  autorequire(:user) do
    [ self[:name], self[:fence_user] ].compact
  end

end



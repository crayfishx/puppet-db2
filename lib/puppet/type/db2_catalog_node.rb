Puppet::Type.newtype(:db2_catalog_node) do

  @doc = %q{
    The db2_catalog_node resource type manages catalog entries for
    nodes on DB2 client instances.
  }


  validate do
    [
      :install_root,
      :instance,
      :type,
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

  newparam(:name, :namevar => true)

  newparam(:instance) do
    desc "Specifies the DB2 instance to use, the username must match the instance name"
  end

  newparam(:to_instance) do
    desc "Name of the instance referred to in the catalog command, not the instance that we are configuring"
  end

  newparam(:install_root) do
    desc "The path to the root of the DB2 installation"
  end

  newparam(:type) do
    desc "Type (protocol) of the node entry, valid options are tcpip, local"
    munge do |value|
      value.downcase
    end
  end

  newparam(:admin, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "When set to true specifies an administration server (tcpip only)"
  end

  newparam(:remote) do
    desc "The hostname or IP address where the database resides (tcpip only)"
  end

  newparam(:server) do
    desc "Specifies the service name or port number of the database manager instance (tcpip only)"
  end

  newparam(:security) do
    desc "Specifies the node will be security enabled, valid values are ssl, ns and server"
    munge do |value|
      value.downcase
    end
  end

  newparam(:remote_instance) do
    desc "Specifies the name of the server instance where the database resides"
  end

  newparam(:system) do
    desc "Specifies the DB2 system name that is used to identify the server machine"
  end

  newparam(:ostype) do
    desc "Specifies the operating system of the server"
  end

  newparam(:comment) do
    desc "A description of the catalog entry"
  end

  autorequire(:db2_instance) do
    self[:instance]
  end

end







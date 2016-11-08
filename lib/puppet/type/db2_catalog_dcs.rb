Puppet::Type.newtype(:db2_catalog_dcs) do

  @doc = %q{
    The db2_catalog_dcs resource type manages catalog entries for
    database connection services (DCS) on DB2 instances.
  }

  validate do
    [
      :install_root,
      :instance,
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

  # database name
  newparam(:name, :namevar => true)

  newparam(:instance) do
    desc "Specifies the DB2 instance to use, the username must match the instance name"
  end

  newparam(:install_root) do
    desc "The path to the root of the DB2 installation"
  end

  newparam(:target) do
    desc "Specifies the name of the target system to catalog"
  end

  newparam(:ar_library) do
    desc "The name of the AR library to load.  Do not specify if using DB2 Connect"
  end

  newparam(:params) do
    desc "Parameters to pass to the application requestor (AR) library"
  end

  newparam(:comment) do
    desc "A description of the catalog entry"
  end

  autorequire(:db2_instance) do
    self[:instance]
  end
end







Puppet::Type.newtype(:db2_catalog_database) do

  @doc = %q{
    The db2_catalog_database resource type manages catalog entries for
    databases on DB2 client instances.

    db2_catalog_database { 'my database': }
  }

 def self.title_patterns
   [
     [ /(^([^\/]*)$)/m,
       [ [:as_alias] ] ],
     [ /^([^:]+):([^:]+)$/,
       [ [:as_alias], [:dbname] ]
     ]
   ]
  end

  validate do
    [
      :install_root,
      :instance,
    ].each do |param|
      if self[param].nil?
        raise ArgumentError, "Must supply parameter #{param}"
      end
    end

    if self[:node] and self[:path]
      raise ArgumentError, "Only one of node or path can be specified"
    end
  end

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:instance) do
    desc "Specifies the DB2 instance to configure (mandatory)"
  end

  newparam(:install_root) do
    desc "The path to the root of the DB2 installation (mandatory)"
  end

  newparam(:as_alias, :namevar => :true) do
    desc "The alias of the database to be cataloged"
  end

  newproperty(:db_name) do
    desc %q{
      The database name to catalog, if this option is ommited then the name of
      the resource title (or as_alias) will be used.
    }
  end

  newproperty(:path) do
    desc "Specify the drive or path where the database resides"
  end

  newproperty(:node) do
    desc "Specify the name of the database partition server where the database resides"
  end

  newproperty(:authentication) do
    desc "Specify an authentication type for local databases.  eg: SERVER, CLIENT, SERVER_ENCRYPT"
  end

  newproperty(:comment) do
    desc "A description of the catalog entry"
  end

  autorequire(:db2_instance) do
    self[:instance]
  end

  autorequire(:db2_catalog_node) do
    self[:node]
  end

end







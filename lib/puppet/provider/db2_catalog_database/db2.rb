require File.join(File.dirname(__FILE__), '..', 'db2.rb')
Puppet::Type.type(:db2_catalog_database).provide(:db2, :parent => Puppet::Provider::Db2) do

  mk_resource_methods

  def exists?
    databases = get_databases
    if databases.has_key?(@resource[:as_alias])
      @property_hash = databases[@resource[:as_alias]]
      true
    else
      false
    end
  end

  def get_databases
    output = db2_exec_nofail('list database directory')
    parse_output(output, :as_alias, {
      /Database alias/ => :as_alias,
      /Database name/  => :db_name,
      /Node name/ => :node,
      /Comment/ => :comment,
      /Authentication/ => :authentication,
      /Local database directory/ => :path,
    })
  end

  def create
    args = [ 'CATALOG DATABASE' ]

    if @resource[:db_name]
      args << [ @resource[:db_name], 'AS', @resource[:as_alias] ]
    else
      args << @resource[:as_alias]
    end

    args << [ 'AT NODE', @resource[:node] ] if @resource[:node]
    args << [ 'ON', @resource[:path] ] if @resource[:path]
    args << [ 'AUTHENTICATION', @resource[:authentication] ] if @resource[:authentication]
    args << "WITH '\"#{@resource[:comment]}\"'" if @resource[:comment]
    db2_exec(args)
    db2_terminate
  end
  
  # This is a strange patch that may need addressing.  DB2 supports adding an authentication type
  # of 'dcs', but this option is not documented on the official CLP commands documentation for
  # the CATALOG DATABASE command.  When configured with dcs, LIST DB DIRECTORY shows the database
  # configured as 'SERVER'.  The only workaround for the moment is to override the authentication
  # method to report that the property is in sync if it set to SERVER but DCS is requested.
  #
  def authentication
    if @property_hash[:authentication] == 'SERVER' and @resource[:authentication].upcase == 'DCS'
      return @resource[:authentication]
    else
      return @property_hash[:authentication]
    end
  end


  def destroy
    args = [ 'UNCATALOG DATABASE' ]
    args << @resource[:as_alias]
    db2_exec(args)
    db2_terminate
  end
end


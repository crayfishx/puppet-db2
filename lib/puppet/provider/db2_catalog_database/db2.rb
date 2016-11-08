require File.join(File.dirname(__FILE__), '..', 'db2.rb')
Puppet::Type.type(:db2_catalog_database).provide(:db2, :parent => Puppet::Provider::Db2) do

  def exists?
    databases = get_databases
    if databases.has_key?(@resource[:as_alias])
      database=databases[@resource[:as_alias]]
      true
    else
      false
    end
  end

  def get_databases
    output = db2_exec('list database directory')
    parse_output(output, :as_alias, {
      /Database alias/ => :as_alias,
      /Database name/  => :db_name,
      /Node name/ => :node,
      /Comment/ => :comment
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
    args << "WITH \"#{@resource[:comment]}\"" if @resource[:comment]
    db2_exec(args)
    db2_terminate
  end
  

  def destroy
    args = [ 'UNCATALOG DATABASE' ]
    args << @resource[:as_alias]
    db2_exec(args)
    db2_terminate
  end
end


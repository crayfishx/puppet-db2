require File.join(File.dirname(__FILE__), '..', 'db2.rb')
Puppet::Type.type(:db2_catalog_dcs).provide(:db2, :parent => Puppet::Provider::Db2) do

  def get_dcs
    output = db2_exec('list dcs directory')
    parse_output(output, :name, {
      /Local database name/ => :name,
      /Target database name/ => :target
    })
  end

  def exists?
    dcs_entries = get_dcs
    if dcs_entries.has_key?(@resource[:name])
      dcs = dcs_entries[@resource[:name]]
      true
    else
      false
    end
  end

  def create
    generate_dcs
  end

  def generate_dcs
    args = [ 'CATALOG', 'DCS' ]
    args << [ 'DATABASE', @resource[:name] ]
    args << [ 'AS', @resource[:target] ] if @resource[:target]
    args << [ 'AR', @resource[:ar_library] ] if @resource[:ar_library]
    args << [ 'PARAMS', @resource[:params] ] if @resource[:params]
    args << "WITH \"#{@resource[:comment]}\"" if @resource[:comment]
    db2_exec(args)
    db2_terminate
  end

  def destroy
    args = [ 'UNCATALOG', 'DCS', @resource[:name] ]
    db2_exec(args)
    db2_terminate
  end

end

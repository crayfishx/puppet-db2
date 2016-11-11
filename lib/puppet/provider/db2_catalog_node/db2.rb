require File.join(File.dirname(__FILE__), '..', 'db2.rb')
Puppet::Type.type(:db2_catalog_node).provide(:db2, :parent => Puppet::Provider::Db2) do

  mk_resource_methods

  def exists?
    nodes = get_nodes
    if nodes.has_key?(resource[:name])
      @property_hash = nodes[resource[:name]]
      true
    else
      false
    end
  end

  def get_nodes
    output_matcher = {
      /Node name/             => :name,
      /Comment/               => :comment,
      /Protocol/              => :protocol,
      /Hostname/              => :remote,
      /Service name/          => :server,
      /Security type/         => :security,
      /Remote instance name/  => :remote_instance,
      /System/                => :system,
      /Operating system type/ => :ostype,
      /Instance name/         => :to_instance,
    }

    # Get the raw output of both regular and admin nodes, there is no single
    # command that combines these
    #
    output_nodes = db2_exec_nofail('list node directory show detail')
    output_admin_nodes = db2_exec_nofail('list admin node directory show detail')

    # Parse the raw output into a hash
    nodes = parse_output(output_nodes, :name, output_matcher)
    admin_nodes = parse_output(output_admin_nodes, :name, output_matcher)

    # Set :admin => true on any admin nodes and return a merged hash of 
    # all results
    #
    admin_nodes.each { |nodename, params| params[:admin] = true}.merge(nodes)
  end

  def create
    generate_node
  end

  def generate_node
    args = [ 'CATALOG' ]
    case @resource[:type]
    when 'tcpip'
      args << 'ADMIN' if @resource[:admin]
      args << 'TCPIP NODE'
      args << @resource[:name]
      args << "REMOTE #{@resource[:remote]}"
      args << "SERVER #{@resource[:server]}" if @resource[:server]
      args << "SECURITY #{@resource[:security].upcase}" if @resource[:security]
      args << "REMOTE_INSTANCE #{@resource[:remote_instance]}" if @resource[:remote_instance]
      args << "SYSTEM #{@resource[:system]}" if @resource[:system]
      args << "OSTYPE #{@resource[:ostype]}" if @resource[:ostype]
      args << "WITH '\"#{@resource[:comment]}\"'" if @resource[:comment]
    when 'local'
      args << 'ADMIN' if @resource[:admin]
      args << 'LOCAL NODE'
      args << @resource[:name]
      args << "INSTANCE #{@resource[:to_instance]}" if @resource[:to_instance]
      args << "SYSTEM #{@resource[:system]}" if @resource[:system]
      args << "OSTYPE #{@resource[:ostype]}" if @resource[:ostype]
      args << "WITH '\"#{@resource[:comment]}\"'" if @resource[:comment]
    end

    db2_exec(args)
    db2_terminate
  end
  
  def destroy
    args = [ 'UNCATALOG NODE' ]
    args << @resource[:name]
    db2_exec(args)
    db2_terminate
  end
end



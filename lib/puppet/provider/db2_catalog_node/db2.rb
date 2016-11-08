require File.join(File.dirname(__FILE__), '..', 'db2.rb')
Puppet::Type.type(:db2_catalog_node).provide(:db2, :parent => Puppet::Provider::Db2) do

  def exists?
    nodes = get_nodes
    if nodes.has_key?(resource[:name])
      node=nodes[resource[:name]]
      true
    else
      false
    end
  end

  def get_nodes
    output = db2_exec('list node directory')
    parse_output(output, :name, {
      /Node name/ => :name,
      /Comment/   => :comment,
      /Protocol/  => :protocol
    })
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
      args << "SERVER #{@resource[:server]}"
      args << "SECURITY #{@resource[:security].upcase}" if @resource[:security]
      args << "REMOTE_INSTANCE #{@resource[:remote_instance]}" if @resource[:remote_instance]
      args << "SYSTEM #{@resource[:system]}" if @resource[:system]
      args << "OSTYPE #{@resource[:ostype]}" if @resource[:ostype]
      args << "WITH \"#{@resource[:comment]}\"" if @resource[:comment]
    when 'local'
      args << 'ADMIN' if @resource[:admin]
      args << 'LOCAL NODE'
      args << @resource[:name]
      args << "INSTANCE #{@resource[:to_instance]}" if @resource[:to_instance]
      args << "SYSTEM #{@resource[:system]}" if @resource[:system]
      args << "OSTYPE #{@resource[:ostype]}" if @resource[:ostype]
      args << "WITH \"#{@resource[:comment]}\"" if @resource[:comment]
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



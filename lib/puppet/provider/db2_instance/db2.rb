require File.join(File.dirname(__FILE__), '..', 'db2.rb')
Puppet::Type.type(:db2_instance).provide(:db2, :parent => Puppet::Provider::Db2) do


  # Returns the fully qualified path to the command given in cmd based
  # on the install_root
  #
  def db2_fqcmd(cmd)
    File.join(@resource[:install_root], cmd)
  end

  def get_instances
    exec_db2_command(db2_fqcmd('instance/db2ilist')).split(/\n/)
  end

  def exists?
    get_instances.include?(@resource[:name])
  end

  def create
    args = [ '-s', @resource[:type], '-a', @resource[:auth] ]
    args << [ '-u', @resource[:fence_user] ] if @resource[:fence_user]
    args << [ '-p', @resource[:port] ] if @resource[:port]
    args << @resource[:name]
    command = [ db2_fqcmd('instance/db2icrt'), args].flatten.join(" ")
    exec_db2_command(command)
  end

  def destroy
    command = [ db2_fqcmd('instance/db2idrop'), @resource[:name] ].flatten.join(" ")
    exec_db2_command(command)
  end
end



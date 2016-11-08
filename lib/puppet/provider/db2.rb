require 'puppet/provider'

class Puppet::Provider::Db2 < Puppet::Provider

  attr_reader :node
  attr_reader :database
  attr_reader :dcs

  def initialize(*args)
    @node = {}
    @database = {}
    @dcs = {}
    super
  end


  # db2_exec.
  # This method calls the db2 command located under the install_root
  # directory and runs it in the correct DB2 instance by setting the
  # DB2INSTANCE environment variable.
  #
  def db2_exec(*args)
    envhash = { "DB2INSTANCE" => @resource[:instance]}
    rootdir = @resource[:install_root]
    executable = File.join(rootdir, 'bin', 'db2')

    command = [ executable, args ].flatten.join(" ")

    self.debug("Using custom environment #{envhash}")
    exec_db2_command(command, envhash)
  end

  def exec_db2_command(command,envhash = {})
    output = Puppet::Util::Execution.execute(
      command,
      :failonfail => true,
      :custom_environment => envhash
    )
  end

  # This is needed to refresh the cache after adding or removing things
  # from the catalog configuration
  #
  def db2_terminate
    db2_exec('terminate')
  end

  # Generic handler to parse the output from db2 list * directory commands.
  # it takes a string dump of the output commands and builds a hash
  # consisting of keys of identifier and the value as a hash of configuration
  # options matched in the keymap hash
  #
  def parse_output (rawstr, identifier, keymap, sep=/\W+=\W/, del=/\n\W*/)
    data_arr = rawstr.split(del)
    result = {}
    ident = nil
    data_arr.each do |line|
      param, val = line.split(sep)
      keymap.each do |matcher, key|
        if param =~ matcher
          if key == identifier
            ident = val
            result[ident] = {}
          else
            if ident
              result[ident][key] = val
            end
          end
        end
      end
    end
    result
  end
end

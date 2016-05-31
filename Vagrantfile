# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
#
  unless File.exists?("#{File.dirname(__FILE__)}/v10.5_linuxx64_server_t.tar.gz")
    puts "***************************************************************"
    puts "The file v10.5_linuxx64_server_t.tar.gz was not found in the"
    puts "working directory. Download the trial version of DB2 from"
    puts "the IBM website and place the file here in order to provision"
    puts "DB2 server using this vagrant box. Vagrant will now continue"
    puts "but provisioning will fail"
    puts "***************************************************************"
  end

Vagrant.configure(2) do |config|
  config.vm.box = "puppetlabs/centos-7.0-64-puppet"

   config.vm.provision "shell", inline: <<-END_SHELL
     
     ## Configure some scaffolding and run the vagrant.pp from the module 
     sudo /opt/puppetlabs/bin/puppet module install puppet-archive
     sudo ln -s /vagrant /etc/puppetlabs/code/environments/production/modules/db2
     sudo /opt/puppetlabs/puppet/bin/puppet apply /vagrant/tests/prereqs.pp
     sudo /opt/puppetlabs/puppet/bin/puppet apply /vagrant/tests/vagrant.pp

     ## If all went well, we should be able to configure the sample database without errors.
     /opt/ibm/db2/V10.5/bin/db2val -a
     sudo -iu db2inst1 db2start
     sudo -iu db2inst1 db2sampl
     sudo -iu db2inst1 db2 'connect to sample'
  END_SHELL
end

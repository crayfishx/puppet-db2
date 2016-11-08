db2_instance { 'db2foo':
  fence_user   => 'db2foof',
  install_root => '/opt/ibm/db2/V11.1',
  auth         => 'server',
  type         => 'client',
}


user { 'db2foo': ensure  => present }
user { 'db2foof': ensure => present }


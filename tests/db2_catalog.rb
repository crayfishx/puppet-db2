

db2_catalog_node { 'DB2T1':
  type => 'tcpip',
  instance => 'db2crgd',
  install_root => '/opt/ibm/db2/V11.1',
  remote => 'db2.example.corp',
  server => '8022',
}
db2_catalog_node { 'MYNODE2':
  type => 'tcpip',
  instance => 'db2crgd',
  install_root => '/opt/ibm/db2/V11.1',
  remote => 'db3.example.corp',
  server => '8024',
}

db2_catalog_database { 'DB2 DB':
  db_name => 'DB2PHHY',
  instance => 'db2crgd',
  install_root => '/opt/ibm/db2/V11.1',
  as_alias   => 'DB2FOO',
  node    => 'MYNODE2',
  authentication => 'dcs',
}

db2_catalog_dcs { 'FOO':
  instance => 'db2crgd',
  install_root => '/opt/ibm/db2/V11.1',
  target => 'BAR'
}
  

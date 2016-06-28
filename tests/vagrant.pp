include db2

## This file is used by vagrant to provision DB2 in a test environment
## and is also a useful example of how to use the module

db2::install { '10.5':
  source     => 'file:///vagrant/v10.5_linuxx64_server_t.tar.gz',
  components => [
  'ACS',
  'APPLICATION_DEVELOPMENT_TOOLS',
  'DB2_SAMPLE_DATABASE   ',
  'BASE_CLIENT',
  'JDK',
  'BASE_DB2_ENGINE',
  'JAVA_SUPPORT',
  'REPL_CLIENT',
  'SQL_PROCEDURES',
  'LDAP_EXPLOITATION',
  'COMMUNICATION_SUPPORT_TCPIP'
  ],
  license_content => template('db2/license/trial.lic'),
}

db2::instance { 'db2inst1':
  fence_user        => 'db2fenc1',
  installation_root => '/opt/ibm/db2/V10.5',
  installer_folder  => 'server_t',
  require           => Db2::Install['10.5'],
}






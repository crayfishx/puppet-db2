class { 'db2':
  installations => {
    '11.1' => {
      'source' => '/vagrant/ibm_data_server_runtime_client_linuxx64_v11.1.tar.gz',
      'product' => 'RUNTIME_CLIENT',
      'components' => [ 'JAVA_SUPPORT', 'LDAP_EXPLOITATION', 'BASE_CLIENT' ],
      'configure_license' => false,
    }
  },
  instances => {
    'db2crgd' => {
      'instance_user_uid' => '10011',
      'type' => 'client',
      'installation_root' => '/opt/ibm/db2/V11.1',
     }
  },
}

      

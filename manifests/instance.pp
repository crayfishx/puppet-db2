# Defined type: db2::instance
#
# Set up a DB2 instance
#
define db2::instance (
  $installation_root,
  $fence_user           = undef,
  $instance_user        = $name,
  $manage_fence_user    = true,
  $manage_instance_user = true,
  $manage_service       = false,
  $fence_user_uid       = undef,
  $fence_user_gid       = undef,
  $fence_user_home      = undef,
  $instance_user_uid    = undef,
  $instance_user_gid    = undef,
  $instance_user_home   = undef,
  $users_forcelocal     = undef,
  $port                 = undef,
  $type                 = 'ese',
  $auth                 = 'server',
  $catalog_databases    = {},
  $catalog_nodes        = {},
  $catalog_dcs          = {},
) {

  if $manage_fence_user {
    if $fence_user {
      user { $fence_user:
        ensure     => present,
        uid        => $fence_user_uid,
        gid        => $fence_user_gid,
        home       => $fence_user_home,
        forcelocal => $users_forcelocal,
        managehome => true,
      }
    }
  }
  if $manage_instance_user {
    user { $instance_user:
      ensure     => present,
      uid        => $instance_user_uid,
      gid        => $instance_user_gid,
      home       => $instance_user_home,
      forcelocal => $users_forcelocal,
      managehome => true,
    }
  }

  if $manage_service {
    if $instance_user_home == undef{
      fail('Please set instance_user_home in order to manage the db2 service instance')
    }

    $instance_service = "db2_${name}.service"

    file{"/etc/systemd/system/${instance_service}":
      ensure  => present,
      content => template('db2/db2_instance.service.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Exec['db2_systemd_daemon_reload'],
    }

    service{$instance_service:
      ensure    => 'running',
      enable    => true,
      subscribe => [
        Exec['db2_systemd_daemon_reload'],
        Db2_instance[$instance_user],
        Db2_catalog_node[keys($catalog_nodes)],
        Db2_catalog_database[keys($catalog_databases)],
        Db2_catalog_dcs[keys($catalog_dcs)],
      ],
    }
  }

  db2_instance { $instance_user:
    install_root => $installation_root,
    fence_user   => $fence_user,
    port         => $port,
    auth         => $auth,
    type         => $type,
  }

  $catalog_defaults = {
    'instance'     => $instance_user,
    'install_root' => $installation_root
  }

  create_resources('db2_catalog_node', $catalog_nodes, $catalog_defaults)
  create_resources('db2_catalog_database', $catalog_databases, $catalog_defaults)
  create_resources('db2_catalog_dcs', $catalog_dcs, $catalog_defaults)

}







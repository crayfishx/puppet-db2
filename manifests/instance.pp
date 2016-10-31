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
        before     => Exec["db2::instance::${name}"],
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
      before     => Exec["db2::instance::${name}"],
    }
  }

  if ( $fence_user )  {
    $fence_user_flag = "-u ${fence_user}"
  } else {
    $fence_user_flag = ''
  }

  if ( $port ) {
    $port_flag = "-p ${port}"
  } else {
    $port_flag = ''
  }


  exec { "db2::instance::${name}":
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    command => "${installation_root}/instance/db2icrt -s ${type} -a ${auth} ${fence_user_flag} ${port_flag} ${instance_user}",
    unless  => "${installation_root}/instance/db2ilist ${instance_user}",
  }
}






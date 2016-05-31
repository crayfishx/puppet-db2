define db2::instance (
  $fence_user,
  $installation_root,
  $instance_user        = $name,
  $manage_fence_user    = true,
  $manage_instance_user = true,
  $fence_user_uid       = undef,
  $fence_user_gid       = undef,
  $fence_user_home      = undef,
  $instance_user_uid    = undef,
  $instance_user_gid    = undef,
  $instance_user_home   = undef,
  $type                 = 'ese',
  $auth                 = 'server',
) {

  if $manage_fence_user {
    user { $fence_user:
      ensure     => present,
      uid        => $fence_user_uid,
      gid        => $fence_user_gid,
      home       => $fence_user_home,
      managehome => true,
      before     => Exec["db2::instance::${name}"],
    }
  }
  if $manage_instance_user {
    user { $instance_user:
      ensure     => present,
      uid        => $instance_user_uid,
      gid        => $instance_user_gid,
      home       => $instance_user_home,
      managehome => true,
      before     => Exec["db2::instance::${name}"],
    }
  }

  exec { "db2::instance::${name}":
    path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin",
    command => "${installation_root}/instance/db2icrt -s ${type} -a ${auth} -u ${fence_user} ${instance_user}",
    unless  => "${installation_root}/instance/db2ilist ${instance_user}"
  }
}






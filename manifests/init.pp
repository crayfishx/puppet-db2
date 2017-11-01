## Class db2
#
# Parameters
#
# *installations*
#   A hash of db2::install types
#
# *instances*
#   A hash of db2::instance types
# 

class db2 (
  $installations = {},
  $instances     = {},
  $workspace     = '/var/puppet_db2',
) {
  ensure_resource('file', $workspace, { 'ensure' => 'directory' })

  create_resources('db2::install', $installations)
  create_resources('db2::instance', $instances)

  Db2::Install<||> -> Db2::Instance<||>

  exec{'db2_systemd_daemon_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

}


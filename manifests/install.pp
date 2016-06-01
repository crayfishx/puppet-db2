#
# Class: db2::install
#
# Prepares the db2 installation file
#
define db2::install (
  $version = $name,
  $extract = true,
  $source  = undef,
  $filename = undef,
  $installer_root    = $::db2::workspace,
  $installer_folder  = 'server_t',
  $install_dest      = undef,
  $product           = 'DB2_SERVER_EDITION',
  $components        = [],
  $languages         = ['EN'],
  $configure_license = true,
  $license_content   = undef,
) {

  # Set up file locations

  $p_install_dest = $install_dest ? {
    undef   => "/opt/ibm/db2/V${version}",
    default => $install_dest
  }

  $binpath="${installer_root}/${installer_folder}"
  $responsefile="${installer_root}/${name}.rsp"


  # Validate paths and filenames
  #

  validate_absolute_path($installer_root)
  validate_absolute_path($binpath)
  validate_absolute_path($responsefile)


  # Extraction of tarball, if $extract is true
  #
  if $extract {

    $p_filename = $filename ? {
      undef     => $source ? {
        undef   => "v${version}_linux64_expc.tar.gz",
        default => regsubst($source, '.*\/', '')
      },
      default   => $filename,
    }
  
    archive { "${installer_root}/${p_filename}":
      ensure       => present,
      extract      => true,
      source       => $source,
      extract_path => $installer_root,
      before       => Exec["db2::install::${name}"],
    }
  }


  file { $responsefile:
    ensure  => file,
    content => template('db2/db2.rsp.erb'),
  }

  exec { "db2::install::${name}":
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    command => "${binpath}/db2setup -r ${responsefile}",
    require => File[$responsefile],
    creates => $p_install_dest,
  }

  if $configure_license {
    if !$license_content {
      fail('Must provide license_content')
    }
    file { "${p_install_dest}/license/custom_${name}.lic":
      ensure  => file,
      content => $license_content,
      require => Exec["db2::install::${name}"],
    }

    exec { "db2::install::license ${name}":
      path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      command     => "${p_install_dest}/adm/db2licm -a ${p_install_dest}/license/custom_${name}.lic",
      refreshonly => true,
      subscribe   => File["${p_install_dest}/license/custom_${name}.lic"],
    }
  }
      
}




  

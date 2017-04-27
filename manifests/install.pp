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
  $installer_folder  = undef,
  $install_dest      = undef,
  $product           = 'DB2_SERVER_EDITION',
  $components        = [],
  $languages         = ['EN'],
  $configure_license = true,
  $license_content   = undef,
  $license_source    = undef,
) {

  # db2 class must be included before db2::install
  if !defined(Class['::db2']) {
    fail('The baseclass db2 must be included before declaring db2::install')
  }

  # Set up file locations

  # Based on the product we try and set some sensible defaults for 
  # filenames and folders, these can be overriden using the 
  # filename and installer_folder attributes to this define
  #
  case $product {
    'DB2_SERVER_EDITION': {
      $default_filename = "v${version}_linux64_expc.tar.gz"
      $default_installer_folder = 'universal'
    }
    'RUNTIME_CLIENT': {
      $default_filename = "ibm_data_server_runtime_client_linuxx64_v${version}.tar.gz"
      $default_installer_folder = 'rtcl'
    }
    default: {}
  }

  # Set the p_installer_folder variable.  This refers to the folder
  # within the installation archive that contains the software
  # to be installed.
  $p_installer_folder = $installer_folder ? {
    undef   => $default_installer_folder,
    default => $installer_folder,
  }

  if (!$p_installer_folder) {
    fail("Unable to determine the installer folder in the archive for ${product}, please specify installer_folder in the instance")
  }

  $p_install_dest = $install_dest ? {
    undef   => "/opt/ibm/db2/V${version}",
    default => $install_dest
  }

  # Binpath refers to the location of the db2setup executable and 
  # is set relative to the installer_root and p_installer_folder
  # above
  $binpath="${installer_root}/${p_installer_folder}"

  # The response file is used by db2setup to determine the type
  # of installation
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
        undef   => $default_filename,
        default => regsubst($source, '.*\/', '')
      },
      default   => $filename,
    }

    if ( !$p_filename ) {
      fail ("Unable to determine default filename for ${product}, please supply a filename to the instance")
    }

    archive { "${installer_root}/${p_filename}":
      ensure       => present,
      extract      => true,
      source       => $source,
      extract_path => $installer_root,
      before       => Exec["db2::install::${name}"],
      creates      => $p_install_dest, # this prevents us using cleanup => true
    }

    # Cleanup after installation is finished
    file { $binpath:
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true, # remove also directories
        backup  => false,
        require => Exec["db2::install::${name}"],
    }
    file { "${installer_root}/${p_filename}":
        ensure  => absent,
        backup  => false,
        require => Exec["db2::install::${name}"],
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

    if !$license_content and !$license_source {
      fail('Must provide license_content or license_source')
    }
    if $license_content and $license_source {
      fail('Must provide only one of license_content or license_source')
    }

    file { "${p_install_dest}/license/custom_${name}.lic":
      ensure  => file,
      content => $license_content,
      source  => $license_source,
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

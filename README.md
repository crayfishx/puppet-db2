[![Build Status](https://travis-ci.org/crayfishx/puppet-db2.svg?branch=unit_testing)](https://travis-ci.org/crayfishx/puppet-db2)

Puppet DB2 module
-----------------

# Contents

1. [Introduction](#introduction)
1. [Prerequisites](#pre-requisistes)
1. [Usage](#usage)
  * [Installing DB2](#db2install)
  * [Configuring DB2 Instances](#db2instance)
  * [Using Hiera to configure DB2 and instances](#db2)
1. [Types and providers](#types-and-providers)
  * [db2_instance](#db2_instance)
  * [db2_catalog_node](#db2_catalog_node)
  * [db2_catalog_database](#db2_catalog_database)
  * [db2_catalog_dcs](#db2_catalog_dcs)
1. [Testing](#testing)


# Introduction 

This module configures DB2 server and runtime client installations and configures instances.

# Pre-requisistes

The DB2 software package ships as an tarball and should be placed either in a Puppet file location, HTTP server or other source location compatible with the `archive` type from `puppet/archive`.   For testing, the 90 day trial of DB2 server can be downloaded from [The IBM DB2 download center](https://www-01.ibm.com/software/data/db2/linux-unix-windows/downloads.html)

Numerous packages and other settings are required in order to support DB2 server, it is recommended that you run the pre-check script from DB2 on the system that you intend to deploy this module to and update your roles/profiles with the relevant pre-reqs for your system.  The script can be found in the source tarball and can be run as

```
# ./db2prereqcheck -l
```

Some warnings can be ignored, please see the IBM documentation for more information

# Usage

This module includes two defined resource types, `db2::install` and `db2::instance`.  `db2::install` is a defined resource type, and not a class, because it's possible to install multiple versions of DB2 server side by side on the same server, so this module allows for that.

This module has only been tested for DB2 10.5, but should work for earlier versions

## `db2::install`

### Usage example for DB2 Server

```puppet
db2::install { '10.5':
  source     => 'http://content.enviatics.com/v10.5_linuxx64_server.tar.gz',
  components => [
    'ACS',
    'APPLICATION_DEVELOPMENT_TOOLS',
    'DB2_SAMPLE_DATABASE   ',
    'BASE_CLIENT',
    'BASE_DB2_ENGINE',
    'JAVA_SUPPORT',
    'SQL_PROCEDURES',
    'COMMUNICATION_SUPPORT_TCPIP'
  ],
  license_content => template('db2/license/trial.lic'),
}
```

### Usage example for DB2 Runtime client

```puppet
db2::install { '11.1':
  source     => 'http://content.enviatics.com/ibm_data_server_runtime_client_linuxx64_v11.1.tar.gz',
  product    => 'RUNTIME_CLIENT',
  components => [
    'JAVA_SUPPORT',
    'BASE_CLIENT'
  ],
  configure_license => false,
}
```

### Parameters

* `version`: set the version of DB2 to be installed (defaults to the resource title)
* `extract`: Whether or not to download and extract the source file (default: true)
* `source`: Source location of the tar.gz file, supports http,ftp,puppet and file URI's (see archive)
* `filename`: Filename of the destination tarball, defaults to filename derived from `source`
* `installer_root`: The root directory of where the tarballs and extracted archives are stored. (default: /var/puppet_db2)
* `installer_folder`: The sub-folder relative to `installer_root` where the installer executables are stored.
* `install_dest`: The target installation folder (default: /opt/ibm/db2/V<version>)
* `product`: The DB2 product ID (default: DB2_SERVER_EDITION)
* `components`: An array of components to install
* `languages`: An array of languages to install (default: [ 'EN' ])
* `configure_license`: Whether or not to configure the license
* `license_content`: The license content as a string (cannot use with license_source)
* `license_source`: The source of the license as a file source parameter (cannot use with license_content)

## `db2::instance`

### Usage example for a DB2 server instance
```puppet
  db2::instance { 'db2inst1':
    fence_user        => 'db2fenc1',
    installation_root => '/opt/ibm/db2/V10.5',
    require           => Db2::Install['10.5'],
  }
```

### Usage example for a DB2 Runtime Client instance
```puppet
  db2::instance { 'db2inst1':
    installation_root => '/opt/ibm/db2/V11.1',
    type              => 'client',
    require           => Db2::Install['11.1'],
  }
```

### Parameters
* `instance_user`: The username for the instance (defaults to resource title)
* `fence_user`: The username of the fence user (optional, must be specified for a non-client instance)
* `installation_root`: The root of the DB2 installation for this instance
* `manage_fence_user`: Whether or not to manage the fence user resource (default: true)
* `fence_user_uid`: UID of the fence user
* `fence_user_gid`: GID of the fence user 
* `fence_user_home`: Home directory of the fence user
* `manage_instance_user`: Whether or not to manage the instance user resource (default: true)
* `instance_user_uid`: UID of the instance user
* `instance_user_gid`: GID of the instance user 
* `instance_user_home`: Home directory of the instance user
* `type`: Type of product this instance is for (default: ese)
* `auth`: Type of auth for this instance (default: server)
* `users_forcelocal`: Force the creation of instance and fence users to be local, true or false. (default: undef)
* `port`: Optionally specify a port name for the instance (default: undef)
* `catalog_databases`: A hash of `[db2_catalog_database](#db2_catalog_database)` resources to pass to create_resources
* `catalog_nodes`: A hash of `[db2_catalog_node](#db2_catalog_node)` resources to pass to create_resources
* `catalog_dcs`: A hash of `[db2_catalog_node](#db2_catalog_node)` resources to pass to create_resources


## `db2`

The db2 base class takes `installations` and `instances` as parameters and farms these to `create_reosurces` to dynamically create DB2 installs and instances from Hiera data.

### Usage sample

```puppet
include db2
```

### Hiera example for DB2 Server Installations
```yaml
db2::installations:
  '10.5':
    source:  'http://content.enviatics.com/v10.5_linuxx64_server.tar.gz'
    components:
      - ACS
      - APPLICATION_DEVELOPMENT_TOOLS
      - DB2_SAMPLE_DATABASE
      - BASE_CLIENT
      - BASE_DB2_ENGINE
      - JAVA_SUPPORT
      - SQL_PROCEDURES
      - COMMUNICATION_SUPPORT_TCPIP

    license_content: |
      [LicenseCertificate]
      CheckSum=8085A37377DB3B127EA410B11BB041AF
      TimeStamp=1356705072
      PasswordVersion=5
      VendorName=IBM Toronto Lab
      ...etc
```

```yaml
db2::instances
  db2inst1:
    fence_user: db2fenc1
    installation_root: /opt/ibm/db2/V10.5
```

### Hiera example for DB2 Runtime Client installations
```yaml
db2::installations:
  '11.1':
    source:  http://content.enviatics.com/ibm_data_server_runtime_client_linuxx64_v11.1.tar.gz
    product: RUNTIME_CLIENT
    components:
      - BASE_CLIENT
      - JAVA_SUPPORT
    configure_license: false
```

```yaml
db2::instances:
  db2inst1:
    type: client
    instance_user_uid: 10111
    installation_root: /opt/ibm/db2/V11.1
```
# Types and Providers

## `db2_instance`

Configures a DB2 instance.   The instance user must already exist (the `db2::instance` defined type does this for you).  

### Example usage

```puppet
db2_instance { 'db2inst1':
  install_root => '/opt/ibm/db2/V11.1',
  type => client,
  fence_user => 'db2fence1',
  auth => 'server',
}
```
  
### Parameters

* `install_root`: Path to the root of the DB2 installation (required)
* `auth`: Authentication type (eg: server) (required)
* `type`: Type of instance (eg: ese, client) (required)
* `fence_user`: The name of the fence user (must already exist with a valid homedir)
* `port`: The port name of the instance

The instance user and fence user will be autorequired by this type, but they must exist already or be in the catalog if calling this type directly.

## `db2_catalog_node`

The `db2_catalog_node` resource type manages the catalog entries for nodes on DB2 instances

### Example usage

```puppet
db2_catalog_node { 'db2node1':
  type => 'tcpip',
  remote => 'db2server.example.com',
  server => 'db2srv',
  security => 'ssl',
}
```

## Parameters

* `install_root`: Path to the root of the DB2 installation (required)
* `instance`: The name of the instance to configure (required)
* `type`: The type of node, currently supported are `tcpip` and `local`
* `to_instance`: Name of the instance referred to in the catalog command, not the instance that we are configuring
* `admin`: When set to true specifies an administration server (tcpip only)
* `remote`: The hostname or IP address where the database resides (tcpip only)
* `server`: The service name or port number of the database manager instance (tcpip only)
* `remote_instance`: Specifies the name of the server instance where the database resides (tcpip only)
* `security`: Specifies the node will be security enabled, valid values are `socks` and `ssl` (tcpip only)
* `system`: Specifies the DB2 system name that is used to identify the server machine
* `ostype`: Specifies the OS type of the server machine (AIX, WIN, HPUX, SUN, OS390, OS400, VM, VSE, SNI, SCO, LINUX and DYNIX.)
* `comment`: A description of the catalog entry

The `db2_catalog_node` resource type will automatically require the corresponding `db2_instance` resource if it is in the catalog

## `db2_catalog_database`

The `db2_catalog_database` resource type manages catalog entries for databases on DB2 instances.

### Usage example

```puppet
db2_catalog_database { 'DB2DBXX':
  instance => 'db2inst1',
  install_root => '/opt/ibm/db2/V11.1',
  node    => 'MYNODE2',
  authentication => 'dcs',
}
```

### Parameters

* `install_root`: Path to the root of the DB2 installation (required)
* `instance`: The name of the instance to configure (required)
* `as_alias`: The alias of the database entry.  This attribute is also the namevar, so if ommited, the resource title will be used as the alias name, this is the unique identifier for the resource
* `db_name`: The database name to catalog, if this option is ommited then the `as_alias` (or the resource title) will be used as the database name
* `path`: Specify the path where the database resides (cannot use with `node`)
* `node`: Specify the name of the database partition server where the database resides (cannot use with `path`)
* `authentication`: Specify an authentication type (SERVER, CLIENT, SERVER_ENCRYPT..etc)
* `comment`: A description of the catalog entry

### Title patterns

The `as_alias` attribute is the resource type's namevar, a short hand notation also exists to map both the `as_alias` and `db_name` attributes from the title of the resource using a comma delimited string as the title.  Therefore, this example;

```puppet
db2_catalog_database { 'DB2 Database X':
  instance => 'db2inst1',
  install_root => '/opt/ibm/db2/V11.1',
  as_alias  => 'DB2X',
  db_name   => 'DB2DBFOO',
  node    => 'MYNODE2',
  authentication => 'dcs',
}
```

... can be written as...

```puppet
db2_catalog_database { 'DB2X:DB2DBFOO'
  instance => 'db2inst1',
  install_root => '/opt/ibm/db2/V11.1',
  node    => 'MYNODE2',
  authentication => 'dcs',
}
```

## `db2_catalog_dcs`

The `db2_catalog_dcs` resource type manages catalog entries for database connection services (DCS) within a DB2 instance.

### Usage example

db2_catalog_dcs { 'DB2DB1':
  instance => 'db2inst1',
  install_root => '/opt/ibm/db2/V11.1',
  target => 'dsn_db_1',
}

### Parameters

* `install_root`: Path to the root of the DB2 installation (required)
* `instance`: The name of the instance to configure (required)
* `target`: The name of the target system to catalog
* `ar_library`: The name of the AR library to load.  Do not specify if using DB2 Connect
* `params`: Parameters to pass to the application requestor (AR) library
* `comment`: A description of the catalog entry




# Testing

## Vagrant

In order to use the boot the vagrant box and set up a DB2 instance to test with, you should first obtain the 90 day trial from IBM's website and place the `v10.5_linuxx64_server_t.tar.gz` in the root directory of this repo.  Then run `vagrant up`.  The provisioner will set up some pre-reqs and run the code from `tests/vagrant.pp`.  It should install DB2, configure an instance, add a sample database using the `SAMPLE_DATABASE` component and connect to it.


# Author

* Written and maintained by Craig Dunn <craig@craigdunn.org> @crayfishx
* Sponsered by Baloise Group [http://baloise.github.io](http://baloise.github.io)



Puppet DB2 module
-----------------

# Introduction 

This module configures DB2 server installations and configures instances.

# Pre-requisistes

The DB2 software package ships as an tarball and should be placed either in a Puppet file location, HTTP server or other source location compatible with the `archive` type from `puppet/archive`.   For testing, the 90 day trial of DB2 can be downloaded from (The IBM website)[https://www-01.ibm.com/software/data/db2/linux-unix-windows/downloads.html]

Numerous packages and other settings are required in order to support DB2 server, it is recommended that you run the pre-check script from DB2 on the system that you intend to deploy this module to and update your roles/profiles with the relevant pre-reqs for your system.  The script can be found in the source tarball and can be run as

```
# ./db2prereqcheck -l
```

Some warnings can be ignored, please see the IBM documentation for more information

# Usage

This module includes two defined resource types, `db2::install` and `db2::instance`.  `db2::install` is a defined resource type, and not a class, because it's possible to install multiple versions of DB2 server side by side on the same server, so this module allows for that.

## `db2::install`

### Usage example

```
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
* `license_content`: The license content as a string

## db2::instance

### Usage example

```puppet
  db2::instance { 'db2inst1':
    fence_user        => 'db2fenc1',
    installation_root => '/opt/ibm/db2/V10.5',
    require           => Db2::Install['10.5'],
  }
```

### Parameters
* `instance_user`: The username for the instance (defaults to resource title)
* `fence_user`: The username of the fence user
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

## db2

The db2 base class takes `installations` and `instances` as parameters and farms these to `create_reosurces` to dynamically create DB2 installs and instances from Hiera data.

### Usage sample

```puppet
include db2
```

### Hiera example
```yaml
db2::installations:
  '10.5':
     source:  'http://content.enviatics.com/v10.5_linuxx64_server.tar.gz',
     components:
      - 'ACS'
      - 'APPLICATION_DEVELOPMENT_TOOLS'
      - 'DB2_SAMPLE_DATABASE   '
      - 'BASE_CLIENT'
      - 'BASE_DB2_ENGINE'
      - 'JAVA_SUPPORT'
      - 'SQL_PROCEDURES'
      - 'COMMUNICATION_SUPPORT_TCPIP'
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
    installation_root: /opt/ibm/db2/V10.5'
```

# Testing

## Vagrant

In order to use the boot the vagrant box and set up a DB2 instance to test with, you should first obtain the 90 day trial from IBM's website and place the `v10.5_linuxx64_server_t.tar.gz` in the root directory of this repo.  Then run `vagrant up`.  The provisioner will set up some pre-reqs and run the code from `tests/vagrant.pp`.  It should install DB2, configure an instance, add a sample database using the `SAMPLE_DATABASE` component and connect to it.





require 'spec_helper'

describe 'db2::install' do

  let :pre_condition do
    'include db2'
  end

  describe "extracting the source" do
    context "when extracting tarball" do
      let(:title) { '11.1' }
      let(:params) {{
        :configure_license => false,
        :source            => 'http://foo/v11.1_linux64_expc.tar.gz',
      }}
    
      it do 
        is_expected.to contain_archive('/var/puppet_db2/v11.1_linux64_expc.tar.gz').with(
          :extract => true,
          :source  => 'http://foo/v11.1_linux64_expc.tar.gz',
          :extract_path => '/var/puppet_db2'
        ).that_comes_before('Exec[db2::install::11.1]')
      end

      it do
        is_expected.to contain_file('/var/puppet_db2/11.1.rsp')
      end
    end
    context "when extracting tarball to a custom filename" do
      let(:title) { '11.1' }
      let(:params) {{
        :configure_license => false,
        :filename          => 'db2.tar.gz',
        :source            => 'http://foo/v11.1_linux64_expc.tar.gz',
      }}
    
      it do 
        is_expected.to contain_archive('/var/puppet_db2/db2.tar.gz').with(
          :extract => true,
          :source  => 'http://foo/v11.1_linux64_expc.tar.gz',
          :extract_path => '/var/puppet_db2'
        ).that_comes_before('Exec[db2::install::11.1]')
      end
    end
    context "when extracting tarball to a custom installer root" do
      let(:title) { '11.1' }
      let(:params) {{
        :configure_license => false,
        :filename          => 'db2.tar.gz',
        :installer_root    => '/var/installers/db2',
        :source            => 'http://foo/v11.1_linux64_expc.tar.gz',
      }}
    
      it do 
        is_expected.to contain_archive('/var/installers/db2/db2.tar.gz').with(
          :extract => true,
          :source  => 'http://foo/v11.1_linux64_expc.tar.gz',
          :extract_path => '/var/installers/db2'
        ).that_comes_before('Exec[db2::install::11.1]')
      end

      it do
        is_expected.to contain_file('/var/installers/db2/11.1.rsp')
      end
    end
    context "when extract is set to false" do
      let(:title) { '11.1' }
      let(:params) {{
        :configure_license => false,
        :extract => false,
        :filename => 'db2.tar.gz'
      }}
    
      it do 
        is_expected.not_to contain_archive('/var/puppet_db2/db2.tar.gz')
      end
    end
  end

  describe "installing" do
    context "when installing server with basic defaults" do
      let (:title) { '11.1' }
      let (:params) {{
        :configure_license => false,
      }}

      it do
        is_expected.to contain_file('/var/puppet_db2/11.1.rsp').with_content(/PROD\W+=\W+DB2_SERVER_EDITION/,
                                                                             /FILE\W+=\W+\/opt\/ibm\/db2\/V11.1/)
      end

      it do
        is_expected.to contain_exec('db2::install::11.1').with(
          :command => '/var/puppet_db2/universal/db2setup -r /var/puppet_db2/11.1.rsp',
          :creates => '/opt/ibm/db2/V11.1'
        ).that_requires('File[/var/puppet_db2/11.1.rsp]')
      end
    end
    context "when installing runtime client with basic defaults" do
      let (:title) { '11.1' }
      let (:params) {{
        :configure_license => false,
        :product => 'RUNTIME_CLIENT'
      }}

      it do
        is_expected.to contain_file('/var/puppet_db2/11.1.rsp').with_content(/PROD\W+=\W+RUNTIME_CLIENT/,
                                                                             /FILE\W+=\W+\/opt\/ibm\/db2\/V11.1/)
      end

      it do
        is_expected.to contain_exec('db2::install::11.1').with(
          :command => '/var/puppet_db2/rtcl/db2setup -r /var/puppet_db2/11.1.rsp',
          :creates => '/opt/ibm/db2/V11.1'
        ).that_requires('File[/var/puppet_db2/11.1.rsp]')
      end
    end
    context "when overriding the installer_folder" do
      let (:title) { '11.1' }
      let (:params) {{
        :configure_license => false,
        :installer_folder  => 'foo',
        :product           => 'RUNTIME_CLIENT',
      }}

      it do
        is_expected.to contain_file('/var/puppet_db2/11.1.rsp').with_content(/PROD\W+=\W+RUNTIME_CLIENT/,
                                                                             /FILE\W+=\W+\/opt\/ibm\/db2\/V11.1/)
      end

      it do
        is_expected.to contain_exec('db2::install::11.1').with(
          :command => '/var/puppet_db2/foo/db2setup -r /var/puppet_db2/11.1.rsp',
          :creates => '/opt/ibm/db2/V11.1'
        ).that_requires('File[/var/puppet_db2/11.1.rsp]')
      end
    end
    context "when overriding the installer_dest location" do
      let (:title) { '11.1' }
      let (:params) {{
        :install_dest  => '/usr/local/db2',
        :license_content => 'foo'
      }}

      it do
        is_expected.to contain_exec('db2::install::11.1').with(
          :creates => '/usr/local/db2'
        )
      end
      it do
        is_expected.to contain_file('/usr/local/db2/license/custom_11.1.lic')
      end

      it do
        is_expected.to contain_exec('db2::install::license 11.1').with(
          :command => '/usr/local/db2/adm/db2licm -a /usr/local/db2/license/custom_11.1.lic',
        ).that_subscribes_to('File[/usr/local/db2/license/custom_11.1.lic]')
      end
    end
    context "when specifying compoenents and languages" do
      let (:title) { '11.1' }
      let (:params) {{
        :configure_license => false,
        :components        => [ 'JAVA_SUPPORT', 'BASE_CLIENT' ],
        :languages         => [ 'EN', 'DE' ],
      }}

      it do
        is_expected.to contain_file('/var/puppet_db2/11.1.rsp').with_content(/^COMP\W+=\W+JAVA_SUPPORT$/,
                                                                             /^COMP\W+=\W+BASE_CLIENT$/,
                                                                             /^LANG\W+=\W+EN$/,
                                                                             /^LANG\W+=\W+DE$/)
      end
    end
  end

  describe "licensing" do
    context "when specifying license content" do
      let(:title) {'11.1' }
      let(:params) {{
        :license_content => "foo\nbar"
      }}

      it do
        is_expected.to contain_file('/opt/ibm/db2/V11.1/license/custom_11.1.lic').with_content("foo\nbar")
      end

      it do
        is_expected.to contain_exec('db2::install::license 11.1').with(
          :command => '/opt/ibm/db2/V11.1/adm/db2licm -a /opt/ibm/db2/V11.1/license/custom_11.1.lic',
          :refreshonly => true
        ).that_subscribes_to('File[/opt/ibm/db2/V11.1/license/custom_11.1.lic]')
      end
    end
    context "when specifying license source" do
      let(:title) {'11.1' }
      let(:params) {{
        :license_source => 'puppet:///modules/profile/db2/license.lic'
      }}

      it do
        is_expected.to contain_file('/opt/ibm/db2/V11.1/license/custom_11.1.lic').with_source('puppet:///modules/profile/db2/license.lic')
      end

      it do
        is_expected.to contain_exec('db2::install::license 11.1').with(
          :command => '/opt/ibm/db2/V11.1/adm/db2licm -a /opt/ibm/db2/V11.1/license/custom_11.1.lic',
          :refreshonly => true
        ).that_subscribes_to('File[/opt/ibm/db2/V11.1/license/custom_11.1.lic]')
      end
    end
    context "when no source or content is given but configure_license is not falsified" do
      let (:title) { '11.1' }
      it do
        is_expected.to raise_error(/Must provide license_content or license_source/)
      end
    end
    context "when both source and content is given" do
      let (:title) { '11.1' }
      let(:params) {{
        :license_source => 'puppet:///modules/profile/db2/license.lic',
        :license_content => "foo\nbar"
      }}
      it do
        is_expected.to raise_error(/Must provide only one of license_content or license_source/)
      end
    end
    context "when configure_license is false" do
      let (:title) { '11.1' }
      let (:params) {{ :configure_license => false }}
      it do
        is_expected.not_to raise_error
      end
    end
  end
end

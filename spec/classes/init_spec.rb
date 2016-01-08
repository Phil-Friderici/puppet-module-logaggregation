require 'spec_helper'
describe 'logaggregation' do
  let(:facts) { {:osfamily => 'RedHat'} }

  platforms = {
    'Debian' =>
      { :osfamily                   => 'Debian',
        :package_name_default       => [ 'eislogging', 'eisloggingnfs', ],
      },
    'RedHat' =>
      { :osfamily                   => 'RedHat',
        :package_name_default       => [ 'EISlogging', 'EISloggingNFS', ],
      },
    'Suse' =>
      { :osfamily                   => 'Suse',
        :package_name_default       => [ 'EISlogging', 'EISloggingNFS', ],
      },
  }

  context 'with default values for all parameters' do
    platforms.sort.each do |k,v|
      context "where osfamily is valid <#{v[:osfamily]}>" do
        let(:facts) { {:osfamily => v[:osfamily] } }

        it { should compile.with_all_deps }
        it { should contain_class('logaggregation') }
        it { should_not contain_class('rsyslog') }
        it { should have_rsyslog__fragment_resource_count(0) }

        v[:package_name_default].each do |package|
          it { should contain_package(package).with_ensure('installed') }
        end

      end # where osfamily is valid <#{v[:osfamily]}
    end # platforms.sort.each

    context "where osfamily is unsupported <UnknownOS>" do
      let(:facts) { {:osfamily => 'UnknownOS' } }

      it 'should fail' do
        expect {
          should contain_class('logaggregation')
        }.to raise_error(Puppet::Error,/logaggregation support package management on osfamilies .*\. Please set logaggregation::manage_packages to <false> for <UnknownOS> hosts\./)
      end

    end # where osfamily is invalid <UnknownOS>
  end # with default values for all parameters

  context 'manage_packages functionality' do
    context 'with manage_packages set to valid <false>' do
      let(:params) { {:manage_packages => false } }

      it { should compile.with_all_deps }
      it { should contain_class('logaggregation') }
      it { should_not contain_package('EISlogging') }
      it { should_not contain_package('EISloggingNFS') }
    end

    context 'with package_name set to a valid array' do
      let(:params) { { :package_name => ['foo','bar'] } }

      it { should compile.with_all_deps }
      it { should contain_class('logaggregation') }
      it { should contain_package('foo').with_ensure('installed') }
      it { should contain_package('bar').with_ensure('installed') }
    end

    context 'with package_name set to a valid string' do
      let(:params) { { :package_name => 'foobar' } }

      it { should compile.with_all_deps }
      it { should contain_class('logaggregation') }
      it { should contain_package('foobar').with_ensure('installed') }
    end

    context 'with package_ensure set to <absent>' do
      let(:params) { { :package_ensure => 'absent' } }

      it { should compile.with_all_deps }
      it { should contain_class('logaggregation') }
      it { should contain_package('EISlogging').with_ensure('absent') }
      it { should contain_package('EISloggingNFS').with_ensure('absent') }
    end
  end # manage_packages functionality

  describe 'rsyslog functionality' do
    let(:default_rsyslog_facts) { {
      :osfamily                => 'RedHat',
      :lsbmajdistrelease       => '6',
    } }

    let(:default_rsyslog_params) { {
      :rsyslog_insight_server  => 'localhost.localnet.local',
      :manage_rsyslog_fragment => true,
    } }

    let(:facts) { default_rsyslog_facts }
    let(:params) { default_rsyslog_params }

    context 'with minimal valid parameters for rsyslog functionality' do

      it { should compile.with_all_deps }
      it { should contain_class('logaggregation') }
      it { should contain_class('rsyslog') }
      it { should have_rsyslog__fragment_resource_count(1) }
      it { should contain_rsyslog__fragment('logaggregation').with({
        :content => "*.* @localhost.localnet.local:514\n",
        })
      }
    end # minimal valid parameters

    context 'with rsyslog_insight_server set to valid <localhost> (as String)' do
      let(:params) { default_rsyslog_params.merge({:rsyslog_insight_server => 'localhost',}) }

      it { should contain_rsyslog__fragment('logaggregation').with({
        :content => "*.* @localhost:514\n",
        })
      }
    end # rsyslog_insight_server

    context 'with rsyslog_insight_port set to valid <1234> (as Fixnum)' do
      let(:params) { default_rsyslog_params.merge({:rsyslog_insight_port => 1234,}) }

      it { should contain_rsyslog__fragment('logaggregation').with({
        :content => "*.* @localhost.localnet.local:1234\n",
        })
      }
    end # rsyslog_insight_port valid


    [-1,0,65536,].each do |port|
      context "with rsyslog_insight_port set to invalid <#{port}> (as #{port.class})" do
        let(:params) { default_rsyslog_params.merge({:rsyslog_insight_port => port,}) }

        it 'should fail' do
          expect {
            should contain_class('logaggregation')
          }.to raise_error(Puppet::Error,/Expected #{port} to be (greater|smaller) or equal to/)
        end
      end # rsyslog_insight_port invalid
    end

    context 'with rsyslog_fragment_epilogue set to valid <#epilogue> (as String)' do
      let(:params) { default_rsyslog_params.merge({:rsyslog_fragment_epilogue => '#epilogue',}) }

      it { should contain_rsyslog__fragment('logaggregation').with({
        :content => "*.* @localhost.localnet.local:514\n#epilogue\n",
        })
      }
    end # rsyslog_fragment_epilogue

    context 'with rsyslog_fragment_file set to valid <insight> (as String)' do
      let(:params) { default_rsyslog_params.merge({:rsyslog_fragment_file => 'insight',}) }

      it { should contain_rsyslog__fragment('insight').with({
        :content => "*.* @localhost.localnet.local:514\n",
        })
      }
    end # rsyslog_fragment_file

    context 'with rsyslog_fragment_preamble set to valid <#preamble> (as String)' do
      let(:params) { default_rsyslog_params.merge({:rsyslog_fragment_preamble => '#preamble',}) }

      it { should contain_rsyslog__fragment('logaggregation').with({
        :content => "#preamble\n*.* @localhost.localnet.local:514\n",
        })
      }
    end # rsyslog_fragment_preamble

    context 'with rsyslog_selector set to valid <kern.crit> (as String)' do
      let(:params) { default_rsyslog_params.merge({:rsyslog_selector => 'kern.crit',}) }

      it { should contain_rsyslog__fragment('logaggregation').with({
        :content => "kern.crit @localhost.localnet.local:514\n",
        })
      }
    end # rsyslog_selector
  end # rsyslog functionality

  describe 'validation of invalid variable type handling' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :kernel            => 'Linux',
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
        :rsyslog_version   => '5.8.10',
      }
    end
    let(:validation_params) do
      {
        :rsyslog_insight_server  => 'localhost.example.net',
        :manage_rsyslog_fragment => true,
      }
    end

    validations = {
      'boolean' => {
        :name    => %w(manage_packages manage_rsyslog_fragment),
        :valid   => [true, false],
        :invalid => ['string',%w(array), { 'ha' => 'sh' }, 3, 2.42],
        :message => '(Unknown type of boolean|Requires either string to work with)',
      },
      'domain_name' => {
        :name    => %w(rsyslog_insight_server),
        :valid   => %w(valid.domain.local),
        :invalid => ['invalid,net', %w(array), { 'ha' => 'sh' }, 2.42 ],
        :message => 'is not a domain name',
      },
      'integer' => {
        :name    => %w(rsyslog_insight_port),
        :valid   => [3],
        :invalid => ['string',%w(array), { 'ha' => 'sh' }, 2.42],
        :message => 'Expected.*to be an Integer',
      },
      'string' => {
        :name    => %w(rsyslog_fragment_epilogue rsyslog_fragment_file rsyslog_fragment_preamble rsyslog_selector),
        :valid   => %w(string),
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:valid].each do |valid|
          context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
            let(:params) { validation_params.merge({ :"#{var_name}" => valid, }) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge({ :"#{var_name}" => invalid, }) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end

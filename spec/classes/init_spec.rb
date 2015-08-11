require 'spec_helper'
describe 'logaggregation' do

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }
    it { should contain_package('EISlogging').with_ensure('installed') }
    it { should contain_package('EISloggingNFS').with_ensure('installed') }

    it { should_not contain_class('rsyslog') }
    it { should have_rsyslog__fragment_resource_count(0) }

  end

  context 'with package_name set to an valid array' do
    let(:params) { { :package_name => ['foo','bar'] } }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }
    it { should contain_package('foo').with_ensure('installed') }
    it { should contain_package('bar').with_ensure('installed') }
  end

  context 'with package_name set to an valid string' do
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
    let(:facts) { {
      :kernel            => 'Linux',
      :osfamily          => 'RedHat',
      :lsbmajdistrelease => '6',
      :rsyslog_version   => '5.8.10',
    } }
    let(:validation_params) { {
      :rsyslog_insight_server  => 'localhost.example.net',
      :manage_rsyslog_fragment => true,
    } }

    validations = {
      'string' => {
        :name    => ['rsyslog_fragment_epilogue','rsyslog_fragment_file','rsyslog_fragment_preamble','rsyslog_selector'],
        :invalid => [3,2.42,['array'],a={'ha'=>'sh'}],
        :message => 'is not a string',
      },
      'integer' => {
        :name    => ['rsyslog_insight_port'],
        :invalid => ['invalid',2.42,['array'],a={'ha'=>'sh'}],
        :message => 'Expected.*to be an Integer',
      },
      'boolean' => {
        :name    => ['manage_rsyslog_fragment'],
        :invalid => ['invalid',3,2.42,['array'],a={'ha'=>'sh'}],
        :message => 'is not a boolean',
      },
      'domain_name' => {
        :name    => ['rsyslog_insight_server'],
        :invalid => ['invalid,net',2.42,['array'],a={'ha'=>'sh'}],
        :message => 'is not a domain name',
      },
    }

    validations.sort.each do |type,var|
      var[:name].each do |var_name|
        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge({:"#{var_name}" => invalid, }) }
            it 'should fail' do
              expect {
                should contain_class(subject)
              }.to raise_error(Puppet::Error,/#{var[:message]}/)
            end
          end # with #{var_name}
        end # var[:fail_on].each
      end # var[:name].each
    end # validations.sort.each
  end # validation of invalid variable types

end

require 'spec_helper'
describe 'logaggregation' do

  context 'with defaults for all parameters' do

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('EISloggingNFS').with_ensure('installed')
    }

    it {
      should contain_package('EISlogging').with_ensure('installed')
    }

  end
  context 'with package_name set' do

    let(:params) { {:package_name => ['foo','bar']} }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('foo').with({
        'ensure' => 'installed',
      })
      should contain_package('bar').with({
        'ensure' => 'installed',
      })
    }
  end
  context 'with package_ensure set' do

    let(:params) { {:package_ensure => 'absent'} }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('EISlogging').with({
        'ensure' => 'absent',
      })
    }
  end
end

require 'spec_helper'
describe 'logaggregation' do

  context 'with defaults for all parameters' do

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('EISlogging').with_ensure('installed')
    }

    it {
      should contain_package('EISloggingNFS').with_ensure('installed')
    }
  end

  context 'with package_name set to an valid array' do

    let(:params) { {:package_name => ['foo','bar']} }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('foo').with_ensure('installed')
    }

    it {
      should contain_package('bar').with_ensure('installed')
    }
  end

  context 'with package_name set to an valid string' do

    let(:params) { {:package_name => 'foobar'} }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('foobar').with_ensure('installed')
    }

  end

  context 'with package_ensure set to <absent>' do

    let(:params) { {:package_ensure => 'absent'} }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('EISlogging').with_ensure('absent')
    }

    it {
      should contain_package('EISloggingNFS').with_ensure('absent')
    }
  end

end

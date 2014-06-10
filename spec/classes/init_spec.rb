require 'spec_helper'
describe 'logaggregation' do

  context 'with defaults for all parameters' do

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('EISlogging').with({
        'ensure' => 'installed',
      })
    }
  end
  context 'with package_name set' do

    let (:params) { package_name => 'foo' }

    it { should compile.with_all_deps }
    it { should contain_class('logaggregation') }

    it {
      should contain_package('foo').with({
        'ensure' => 'installed',
      })
    }
  end
end

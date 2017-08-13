require 'spec_helper'

describe 'bareos::director' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_class('bareos::director') }
        it { is_expected.to contain_package('bareos-director') }
        it { is_expected.to contain_package('bareos-database-postgresql') }
        it { is_expected.to contain_package('bareos-bconsole') }
      when 'RedHat'
        it { is_expected.to contain_package('bareos-director') }
        it { is_expected.to contain_package('bareos-bconsole') }
      end
    end
  end
end

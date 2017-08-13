require 'spec_helper'

describe 'bareos::storage' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('bareos::storage') }

      case facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_package('bareos-storage') }
      when 'RedHat'
        it { is_expected.to contain_package('bareos-storage') }
      end
    end
  end
end

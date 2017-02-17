require 'spec_helper'

describe 'bareos::director' do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context "on #{os}" do

      case facts[:osfamily]
      when 'Debian'
        it { should contain_class('bareos::director') }
      end

    end
  end
end

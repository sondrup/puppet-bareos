require 'spec_helper'

describe 'bareos::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      it { is_expected.to contain_class('bareos::client') }
    end
  end
end

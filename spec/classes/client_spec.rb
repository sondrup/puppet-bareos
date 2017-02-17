require 'spec_helper' 

describe 'bareos::client' do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context "on #{os}" do
      it { should contain_class('bareos::client') }
    end
  end
end


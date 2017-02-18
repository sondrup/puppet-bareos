require 'spec_helper'

describe 'bareos::storage' do
  require 'hiera'
  let(:hiera_config) { 'hiera.yaml' }
  context 'Debian' do
    let(:facts) {
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :concat_basedir  => '/dne',
        :ipaddress       => '10.0.0.1',
        # puppetlabs-apt dependent facts
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'jessie',
        :puppetversion   => Puppet.version,
      }
    }
    it { should contain_class('bareos::storage') }
  end
  context 'RedHat' do
    let(:facts) {
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '7.0',
        :operatingsystemmajrelease => '7',
        :concat_basedir => '/dne',
        :ipaddress => '10.0.0.1'
      }
    }
    it { should contain_class('bareos::storage') }
  end
end

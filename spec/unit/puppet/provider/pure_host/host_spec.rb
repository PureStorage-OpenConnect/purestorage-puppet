require 'spec_helper'

describe Puppet::Type.type(:pure_host).provider(:host) do

  before :each do
    Puppet::Type.type(:pure_host).stub(:defaultprovider).and_return described_class
    @transport = double(:transport)
    @device    = double(:device)
    allow(@device).to receive(:transport) { @transport }
  end

  let :resource do
    Puppet::Type.type(:pure_host).new(
      :name   => 'pure_host',
      :ensure => :present
    )
  end

  let :provider do
    described_class.new(
      :name => 'pure_host'
    )
  end

  describe 'when asking exists?' do
    it 'should return true if resource is present' do
      resource.provider.set(:ensure => :present)
      resource.provider.should be_exists
    end
    it 'should return false if resource is absent' do
      resource.provider.set(:ensure => :absent)
      resource.provider.should_not be_exists
    end
  end

  describe '#instances' do
    it 'should return an array of current hosts' do
      expect(@transport).to receive(:getRestCall).with('/host') { JSON.parse(File.read(my_fixture('host-list.json'))) }
      allow(described_class).to receive(:transport) { @transport }

      instances = described_class.instances
      instances.size.should eq(1)

      instances.map do |prov|
        {
          :name    => prov.get(:name),
          :ensure  => prov.get(:ensure),
          :iqnlist => prov.get(:iqnlist),
          :wwnlist => prov.get(:wwnlist),
        }
      end.should == [
        {
          :name    => 'host01',
          :ensure  => resource[:ensure],
          :iqnlist => [ '123456' ],
          :wwnlist => [ '51402EC0017AA6B4' ]
        }
      ]
    end

    describe '#prefetch' do
      it 'exists' do
        expect(@transport).to receive(:getRestCall).with('/host') { JSON.parse(File.read(my_fixture('host-list.json'))) }
        allow(described_class).to receive(:transport) { @transport }
        current_provider = resource.provider
        resources = { 'volume-name' => resource }
        described_class.prefetch(resources)
        expect(resources['volume-name']).not_to be(current_provider)
      end
    end

    describe 'when creating a volume' do
      it 'should be able to create it' do
        expect(@transport).to receive(:executeHostRestApi).with('create', 'pure_host', nil, nil)
        allow(resource.provider).to receive(:transport) { @transport }
        resource.provider.create
      end
    end

    describe 'when destroying a volume' do
      it 'should be able to delete it' do
        expect(@transport).to receive(:executeHostRestApi).with('delete', 'pure_host')
        allow(resource.provider).to receive(:transport) { @transport }
        resource.provider.set(:name => 'pure_host')
        resource.provider.destroy
        resource.provider.flush
      end
    end

    describe 'when modifying a volume' do
      describe 'for iqnlist' do
        it "should be able to update iqnlist" do
          expect(@transport).to receive(:executeHostRestApi).with('update', 'pure_host', ['123456'], nil)
          allow(resource.provider).to receive(:transport) { @transport }
          # resource.provider.set(:name => 'pure_vol', :size => '10G')
          resource[:iqnlist] = ['123456']
          resource.provider.flush
        end
      end

      describe 'for wwnlist' do
        it "should be able to update wwnlist" do
          expect(@transport).to receive(:executeHostRestApi).with('update', 'pure_host', nil, ['abcdef'])
          allow(resource.provider).to receive(:transport) { @transport }
          # resource.provider.set(:name => 'pure_vol', :size => '10G')
          resource[:wwnlist] = ['abcdef']
          resource.provider.flush
        end
      end
    end
  end
end

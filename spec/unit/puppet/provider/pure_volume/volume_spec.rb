require 'spec_helper'

describe Puppet::Type.type(:pure_volume).provider(:volume) do

  before :each do
    Puppet::Type.type(:pure_volume).stub(:defaultprovider).and_return described_class
    @transport = double(:transport)
    @device = double(:device)
    allow(@device).to receive(:transport) { @transport }
  end

  let :resource do
    Puppet::Type.type(:pure_volume).new(
      :volume_name => 'pure_vol',
      :ensure      => :present,
      :volume_size => '10G'
    )
  end

  let :provider do
    described_class.new(
      :name => 'pure_vol'
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
    it 'should return an array of current volumes' do
      expect(@transport).to receive(:getRestCall).with('/volume') { JSON.parse(File.read(my_fixture('volume-list.json'))) }
      allow(described_class).to receive(:transport) { @transport }

      instances = described_class.instances
      instances.size.should eq(2)

      instances.map do |prov|
        {
          :name   => prov.get(:volume_name),
          :ensure => prov.get(:ensure),
          :size   => prov.get(:volume_size)
        }
      end.should == [
        {
          :name   => 'vol1',
          :ensure => resource[:ensure],
          :size   => '30G'
        },
        {
          :name   => 'vol2',
          :ensure => resource[:ensure],
          :size   => '14T'
        }]
    end

    describe '#prefetch' do
      it 'exists' do
        expect(@transport).to receive(:getRestCall).with('/volume') { JSON.parse(File.read(my_fixture('volume-list.json'))) }
        allow(described_class).to receive(:transport) { @transport }
        current_provider = resource.provider
        resources = { 'volume-name' => resource }
        described_class.prefetch(resources)
        expect(resources['volume-name']).not_to be(current_provider)
      end
    end

    describe 'when creating a volume' do
      it 'should be able to create it' do
        expect(@transport).to receive(:executeVolumeRestApi).with('create', 'pure_vol', '10G')
        allow(resource.provider).to receive(:transport) { @transport }
        resource.provider.create
      end
    end

    describe 'when destroying a volume' do
      it 'should be able to delete it' do
        expect(@transport).to receive(:executeVolumeRestApi).with('delete', 'pure_vol')
        allow(resource.provider).to receive(:transport) { @transport }
        resource.provider.set(:volume_name => 'pure_vol')
        resource.provider.destroy
        resource.provider.flush
      end
    end

    describe 'when modifying a volume' do
      describe 'for #volume_size=' do
        it "should be able to increase a volume size" do
          expect(@transport).to receive(:executeVolumeRestApi).with('update', 'pure_vol', '20G')
          allow(resource.provider).to receive(:transport) { @transport }
          # resource.provider.set(:volume_name => 'pure_vol', :volume_size => '10G')
          resource[:volume_size] = '20G'
          resource.provider.send("volume_size=", '20G')
        end
      end
    end
  end
end

require 'spec_helper'

describe Puppet::Type.type(:pure_volume).provider(:volume) do

  before :each do
    allow(Puppet::Type.type(:pure_volume)).to receive(:defaultprovider).and_return described_class
    @transport = double(:transport)
    @device    = double(:device)
    allow(@device).to receive(:transport) { @transport }
  end

  let :resource do
    Puppet::Type.type(:pure_volume).new(
      :name   => 'pure_vol',
      :ensure => :present,
      :size   => '10G'
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
      expect(resource.provider).to be_exists
    end
    it 'should return false if resource is absent' do
      resource.provider.set(:ensure => :absent)
      expect(resource.provider).to_not be_exists
    end
  end

  describe '#instances' do
    it 'should return an array of current volumes' do
      expect(@transport).to receive(:getRestCall).with('/volume') { JSON.parse(File.read(my_fixture('volume-list.json'))) }
      allow(described_class).to receive(:transport) { @transport }

      instances = described_class.instances
      expect(instances.size).to eq(2)

      expect(instances.map do |prov|
        {
          :name   => prov.get(:name),
          :ensure => prov.get(:ensure),
          :size   => prov.get(:size)
        }
      end).to eq([
        {
          :name   => 'vol1',
          :ensure => resource[:ensure],
          :size   => '30G'
        },
        {
          :name   => 'vol2',
          :ensure => resource[:ensure],
          :size   => '14T'
        }
      ])
    end
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
      resource.provider.set(:name => 'pure_vol')
      resource.provider.destroy
      resource.provider.flush
    end
  end

  describe 'when modifying a volume' do
    describe 'for #size=' do
      it "should be able to increase a volume size" do
        expect(@transport).to receive(:executeVolumeRestApi).with('update', 'pure_vol', '20G')
        allow(resource.provider).to receive(:transport) { @transport }
        # resource.provider.set(:name => 'pure_vol', :size => '10G')
        resource[:size] = '20G'
        resource.provider.send("size=", '20G')
      end
    end
  end
end

require 'spec_helper'

describe Puppet::Type.type(:pure_connection).provider(:connection) do

  before :each do
    allow(Puppet::Type.type(:pure_connection)).to receive(:defaultprovider).and_return described_class
    @transport = double(:transport)
    @device    = double(:device)
    allow(@device).to receive(:transport) { @transport }
  end

  let :resource do
    Puppet::Type.type(:pure_connection).new(
      :title       => 'host_01:vol_01',
      :host_name   => 'host_01',
      :ensure      => :present,
      :volume_name => 'vol_01'
    )
  end

  let :provider do
    described_class.new(
      :title => 'host_01:vol_01'
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
    it 'should return an array of current host:volume connections' do
      expect(@transport).to receive(:getRestCall).with('/volume?connect=true') { JSON.parse(File.read(my_fixture('volume-connection-list.json'))) }
      allow(described_class).to receive(:transport) { @transport }

      instances = described_class.instances
      expect(instances.size).to eq(2)

      expect(instances.map do |prov|
        {
          :host_name   => prov.get(:host_name),
          :ensure      => prov.get(:ensure),
          :volume_name => prov.get(:volume_name)
        }
      end).to eq([
        {
          :host_name   => 'host01',
          :ensure      => resource[:ensure],
          :volume_name => 'vol01'
        },
        {
          :host_name   => 'host01',
          :ensure      => resource[:ensure],
          :volume_name => 'vol02'
        }
      ])
    end
  end

  describe '#prefetch' do
    it 'exists' do
      expect(@transport).to receive(:getRestCall).with('/volume?connect=true') { JSON.parse(File.read(my_fixture('volume-connection-list.json'))) }
      allow(described_class).to receive(:transport) { @transport }
      current_provider = resource.provider

      # Create a catalog
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource

      # Dup the resource
      prefetch_resource = resource.dup
      prefetch_resource.catalog = catalog

      resources = { 'host-name' => prefetch_resource }
      described_class.prefetch(resources)
      expect(resources['host-name']).not_to be(current_provider)
    end
  end

  describe 'when creating a connection' do
    it 'should be able to create it' do
      expect(@transport).to receive(:executeConnectionRestApi).with('create', 'host_01', 'vol_01')
      allow(resource.provider).to receive(:transport) { @transport }
      resource.provider.create
    end
  end

  describe 'when destroying a connection' do
    it 'should be able to delete it' do
      expect(@transport).to receive(:executeConnectionRestApi).with('delete', 'host_01', 'vol_01')
      allow(resource.provider).to receive(:transport) { @transport }
      resource.provider.destroy
    end
  end

end

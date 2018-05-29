require 'net/http'
require 'puppet/purestorage_api'
require 'puppet/provider/pure'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

Puppet::Type.type(:pure_volume).provide(:volume,
                                      :parent => Puppet::Provider::Pure) do
  desc "Provider for type PureStorage volume."

  mk_resource_methods

  def self.instances
    volumes = []

    # Get a list of volumes from Pure array
    results = transport.getRestCall('/volume')
    Puppet.debug("Got results: #{results.inspect}")
    results.each do |volume|
      Puppet.debug("Volume: #{volume.inspect}")
      volume_hash = {
        :name   => volume['name'],
        :ensure => :present
      }

      # Need to convert from bytes to biggest possible unit
      vol_size_bytes = volume['size']
      vol_size_mb = vol_size_bytes / 1024 / 1024
      if vol_size_mb % 1024 == 0
        vol_size_gb = vol_size_mb / 1024
        if vol_size_gb % 1024 == 0
          vol_size_tb = vol_size_gb / 1024
          vol_size = vol_size_tb.to_s + "T"
        else
          vol_size = vol_size_gb.to_s + "G"
        end
      else
        vol_size = vol_size_mb.to_s + "M"
      end
      volume_hash[:size] = vol_size

      Puppet.debug("Volume_hash looks like: #{volume_hash}")

      # Add volume to list of volumes
      volumes << new(volume_hash)
    end

    volumes
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    Puppet.debug("Flushing resource #{resource[:name]}: #{resource.inspect}")
    if @property_hash[:ensure] == :absent
      transport.executeVolumeRestApi(self.class::DELETE, resource[:name])
    end
  end

  def create
    Puppet.debug("<<<<<<<<<< Inside volume create for volume: #{resource[:name]} ")
    transport.executeVolumeRestApi(self.class::CREATE, resource[:name], resource[:size])
  end

  def destroy
    Puppet.debug("Triggering destroy for #{resource[:name]}")
    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.debug("Checking existence...")
    @property_hash[:ensure] == :present
  end

  # size setter
  def size=(value)
    Puppet.debug("Puppet::Provider::Volume size=: setting volume size for volume #{resource[:name]}")
    transport.executeVolumeRestApi(self.class::UPDATE, resource[:name], value)
  end
end


require 'net/http'
require 'facter'

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
        :volume_name => volume['name'],
        :ensure      => :present
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
      volume_hash[:volume_size] = vol_size

      Puppet.debug("Volume_hash looks like: #{volume_hash}")

      # Add volume to list of volumes
      volumes << new(volume_hash)
    end

    volumes
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.volume_name]
        resource.provider = prov
      end
    end
  end

  def flush
    if @property_hash[:ensure] == :absent
      transport.executeVolumeRestApi(self.class::DELETE, resource[:volume_name])
    end
  end

  def create
    Puppet.debug("<<<<<<<<<< Inside volume create for volume: #{resource[:volume_name]} ")
    transport.executeVolumeRestApi(self.class::CREATE, resource[:volume_name], resource[:volume_size])
  end

  def destroy
    Puppet.debug("Triggering destroy for #{resource[:volume_name]}")
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # Volume_size setter
  def volume_size=(value)
    Puppet.debug("Puppet::Provider::Volume volume_size=: setting volume size for volume #{resource[:volume_name]}")
    transport.executeVolumeRestApi(self.class::UPDATE, resource[:volume_name], resource[:volume_size])
  end
end


require 'net/http'
require 'puppet/purestorage_api'
require 'puppet/provider/pure'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

Puppet::Type.type(:pure_connection).provide(:connection,
                                :parent => Puppet::Provider::Pure) do
  desc "This is a provider for creating private connection between host and volume."

  mk_resource_methods

  def self.instances
    connections = []

    # Get a list of volume connections from Pure array
    results = transport.getRestCall('/volume?connect=true')
    Puppet.debug("Got results: #{results.inspect}")

    results.each do |connection|
      connection_hash = {
        :host_name   => connection['host'],
        :ensure      => :present,
        :volume_name => connection['name']
      }

      Puppet.debug("Connection resource looks like: #{connection_hash.inspect}")
      connections << new(connection_hash)
    end

    connections
  end

  def self.prefetch(resources)
    catalog = resources.values.first.catalog
    instances.each do |prov|
      catalog.resources.each do |item|
        if item.class.to_s == 'Puppet::Type::Pure_connection' \
          && item[:host_name] == prov.host_name \
          && item.parameter('volume_name').value == prov.volume_name
          item.provider = prov
        end
      end
    end
  end

  def create
    Puppet.debug("<<<<<<<<<< Inside connection create")
    transport.executeConnectionRestApi(self.class::CREATE,resource[:host_name],resource[:volume_name])
  end

  def destroy
    Puppet.debug("<<<<<<<<<< Inside connection destroy")
    transport.executeConnectionRestApi(self.class::DELETE,resource[:host_name],resource[:volume_name])
  end

  def exists?
    @property_hash[:ensure] == :present
  end

end


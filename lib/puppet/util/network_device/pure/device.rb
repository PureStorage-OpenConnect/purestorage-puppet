require 'puppet/util/network_device'
require 'puppet/util/network_device/pure'
require 'puppet/util/network_device/pure/facts'
require 'puppet/purestorage_api'

class Puppet::Util::NetworkDevice::Pure::Device

  attr_accessor :transport
  def initialize(url, option = {})
    @transport = PureStorageApi.new(url)
    @url = url
    Puppet.debug("Inside Device Initialize URL :" + url)
  end

  def facts
    Puppet.debug("Inside Device FACTS Initialize URL :" + @url)
    @facts ||= Puppet::Util::NetworkDevice::Pure::Facts.new(@transport, @url)
    Puppet.debug("After creating FACTS Object !!!")
    thefacts = @facts.retrieve
    thefacts
  end

end

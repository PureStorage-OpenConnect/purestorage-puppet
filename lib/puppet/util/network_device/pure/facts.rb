require 'puppet/util/network_device/pure'
require 'puppet/purestorage_api'

class Puppet::Util::NetworkDevice::Pure::Facts

  attr_reader :transport, :url
  def initialize(trasport, url)
    @transport = transport
    @url = url
    Puppet.debug("Inside Initialize of Facts!")
  end

  def retrieve
    Puppet.debug("Retrieving Facts from fact.rb!")
    @facts = {}
    @facts["url"] = @url 
    @facts["vendor_id"] = 'pure'
    @facts
  end
end

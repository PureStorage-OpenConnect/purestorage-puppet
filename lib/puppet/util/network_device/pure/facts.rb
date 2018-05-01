require 'puppet/util/network_device/pure'
require 'puppet/purestorage_api'

class Puppet::Util::NetworkDevice::Pure::Facts

  attr_reader :transport
  def initialize(trasport)
    @transport = transport
    Puppet.debug("Inside Initialize of Facts!")
  end

  def retrieve
    Puppet.debug("Retrieving Facts from fact.rb!")
    Puppet.debug("Transport = #{@transport.inspect}")
    array_info = @transport.getRestCall('/array')
    Puppet.debug("Array_info = #{array_info.inspect}")

    @facts = {}
    @facts['array_name'] = array_info['array_name']
    @facts['vendor_id'] = 'pure'
    @facts['version'] = array_info['version']
    @facts
  end
end

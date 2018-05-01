require 'puppet/util/network_device/pure'
require 'puppet/purestorage_api'

class Puppet::Util::NetworkDevice::Pure::Facts
  attr_reader :transport, :facts

  def initialize(transport)
    @transport = transport
  end

  def retrieve
    Puppet.debug("Fetching facts from Pure Array")
    array_info = @transport.getRestCall('/array')
    Puppet.debug("Returned array info = #{array_info.inspect}")

    controller_info = @transport.getRestCall('/array?controllers=true')
    Puppet.debug("Returned controller info =#{controller_info.inspect}")

    @facts = {}
    @facts['array_name']  = array_info[:array_name]
    @facts['controllers'] = controller_info
    @facts['vendor_id']   = 'pure'
    @facts['version']     = array_info[:version]
    @facts
  end
end

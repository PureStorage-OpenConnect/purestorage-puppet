#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================

require 'puppet/provider'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

class Puppet::Provider::Pure < Puppet::Provider
   CREATE            = "create"
   UPDATE            = "update"
   DELETE            = "delete"
    
  def self.transport(args=nil)
    @device ||= Puppet::Util::NetworkDevice.current
    if not @device and Facter.value(:url)
      Puppet.debug "@@@@ NetworkDevice::Pure: connecting via facter url."
      @device ||= Puppet::Util::NetworkDevice::Pure::Device.new(Facter.value(:url))
    elsif not @device and args and args.length == 1
      Puppet.debug "@@@@ NetworkDevice::Pure: connecting via argument bits #{args[0]}."
      @device ||= Puppet::Util::NetworkDevice::Pure::Device.new(args[0])
    end
    raise Puppet::Error, "#{self.class} : device not initialized " \
                           "#{caller.join("\n")}" unless @device
    @transport = @device.transport
  end

  def transport(*args)
    # this calls the class instance of self.transport instead of the object
    # instance which causes an infinite loop.
    self.class.transport(args)
  end
end

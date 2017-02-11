require 'net/http'
require 'facter'

require 'puppet/purestorage_api'
require 'puppet/provider/pure'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

Puppet::Type.type(:volume).provide(:volume,
                                      :parent => Puppet::Provider::Pure) do
    desc "Provider for type PureStorage volume."

    def create
       Puppet.debug("<<<<<<<<<< Inside volume create & operation:"+@operation)	
      transport.executeVolumeRestApi(@operation,@volume_name,@volume_size)	
    end

    def destroy
       Puppet.debug("<<<<<<<<<< Inside volume destroy & operation:"+@operation)
      transport.executeVolumeRestApi(@operation,@volume_name,@volume_size)	
    end

    def exists?
      Puppet.debug("<<<<<<<<<< Inside volume exists?")
      @volume_name =  resource[:volume_name]
    	@volume_size = resource[:volume_size]
      @ensure = resource[:ensure]
      @url  = resource[:device_url]  
        
     	Puppet.debug "volume_name :" + @volume_name
      Puppet.debug "volume_size :" + @volume_size
      Puppet.debug "ensure :" + @ensure.to_s
      Puppet.debug "url :" + @url.to_s

      # Set FACT for URL 
      if(!@url.to_s.nil?)
        command_echo = 'echo '+@url.to_s
        Facter.add(:url) do
          setcode command_echo 
        end 
      end     
    
      #Check volume  existence  
      isExists =  transport.isVolumeExists(@volume_name,@volume_size)
      Puppet.info("\n Is volume:'"+@volume_name+"' exists? "+ isExists.to_s)
      
      #Decide which operation to do Create\Update\Delete 
      if(@ensure == :present)
        if(isExists)
          @operation= self.class::UPDATE #"update"
          isExists = false  
        else
          @operation= self.class::CREATE #"create"
        end  
      elsif(@ensure == :absent)
        @operation= self.class::DELETE #"delete"
      end
      
      Puppet.debug("<<<<<<<<<< Operation to perform? "+ @operation)    
      return isExists
    end
end



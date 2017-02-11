require 'net/http'
require 'puppet/purestorage_api'
require 'puppet/provider/pure'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

Puppet::Type.type(:hostconfig).provide(:hostconfig,
                                :parent => Puppet::Provider::Pure) do
    desc "Provider for PureStorage host."

    def create
       Puppet.debug("<<<<<<<<<< Inside hostconfig create & operation:"+@operation)	
      transport.executeHostRestApi(@operation,@host_name,@host_iqnlist)	
    end

    def destroy
       Puppet.debug("<<<<<<<<<< Inside hostconfig destroy & operation:"+@operation)
      transport.executeHostRestApi(@operation,@host_name,@host_iqnlist)	
    end

    def exists?
       Puppet.debug("<<<<<<<<<< Inside hostconfig exists?")
      	@host_name =  resource[:host_name]
      	@host_iqnlist = resource[:host_iqnlist]
      	@ensure = resource[:ensure]
      	@url  = resource[:device_url]
      	   
      	#@host_wwnlist = resource[:host_wwnlist]
       	Puppet.debug "host_name :" + @host_name
        Puppet.debug "host_iqnlist :" + @host_iqnlist.to_s
        Puppet.debug "ensure :" + @ensure.to_s
        #Puppet.debug "host_wwnlist :" + @host_wwnlist
        Puppet.debug "url :" + @url.to_s

        # Set FACT for URL        
        if(!@url.to_s.nil?)
          command_echo = 'echo '+@url.to_s
          Facter.add(:url) do
            setcode command_echo 
          end 
        end     
        
        #Check host existence  
        isExists =  transport.isHostExists(@host_name,@host_iqnlist)
        
       Puppet.info("\n Is host: '"+@host_name+"' exists? "+ isExists.to_s)
      
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



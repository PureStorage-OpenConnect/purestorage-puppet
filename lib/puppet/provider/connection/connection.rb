require 'net/http'
require 'puppet/purestorage_api'
require 'puppet/provider/pure'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

Puppet::Type.type(:connection).provide(:connection,
                                :parent => Puppet::Provider::Pure) do
    desc "This is a provider for creating private connection between host and volume."

    def create
       Puppet.debug("<<<<<<<<<< Inside connection create")	
      transport.executeConnectionRestApi(self.class::CREATE,@host_name,@volume_name)	
    end

    def destroy
       Puppet.debug("<<<<<<<<<< Inside connection destroy")
      transport.executeConnectionRestApi(self.class::DELETE,@host_name,@volume_name)	
    end

    def exists?
       Puppet.debug("<<<<<<<<<< Inside connection exists?")
       @host_name =  resource[:host_name]
       @volume_name =  resource[:volume_name]
       @url  = resource[:device_url] 
         
       	Puppet.debug("host_name :" + @host_name)
        Puppet.debug("volume_name :" + @volume_name)
        Puppet.debug("url :" + @url.to_s)
        
        #Set FACT for "url"
        if(!@url.to_s.nil?)
              command_echo = 'echo '+@url.to_s
              Facter.add(:url) do
                setcode command_echo 
              end 
        end     
       
        #Check connection existence     
       isExists =  transport.isConnectionExists(@host_name,@volume_name)
       
       Puppet.info("\n Is connection between host :'"+@host_name+"' and volume: '"+ @volume_name +"' exists? "+ isExists.to_s)
      return isExists
    end
end



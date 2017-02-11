Puppet::Type.newtype(:hostconfig) do
      @doc = "It does CRUD operations for hosts on a Pure Storage flash array."
      
     apply_to_all
     ensurable
      
      newparam(:host_name) do 
        desc "The name of the host."
        isnamevar
        validate do |value|
          fail("host name can not be empty or null: #{value}") if value == "null" or value.strip.empty?
        end
      end
      
      newparam(:host_iqnlist) do
   	    desc "The iqnlist"
     	  validate do |value|
          fail("host iqn_list can not be null string: #{value}") if value == "null" or value.to_s == ''
     	  end
      end
  
      newparam(:device_url) do
          desc "URL in the form of https://<user>:<passwd>@<FQ_Device_Name or IP>"
      end
# Not Supported for V1.0      
#      newparam(:host_wwnlist) do
#      desc "The wwnlist"
#      end
 end

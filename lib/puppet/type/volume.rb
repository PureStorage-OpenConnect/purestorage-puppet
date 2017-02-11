Puppet::Type.newtype(:volume) do
      @doc = "It does CRUD operations for volumes on a Pure Storage flash array."
      
      validate do
        self.fail "volume size attribute is mandatory" if !self[:volume_size]
      end 
      
      apply_to_all
      ensurable
      
      newparam(:volume_name) do
  	 	desc "The name of the volume."
      isnamevar
        validate do |value|
          fail("volume name can not be empty or null: #{value}") if value == "null" or value.strip.empty?
        end
      end
      
      newparam(:volume_size) do
  	 	desc "The volume size in GB e.g. 1G "
        validate do |value|
          fail("volume size can not be empty or null: #{value}") if value == "null" or value.strip.empty?
        end
      end
      
      newparam(:device_url) do
        desc "URL in the form of https://<user>:<passwd>@<FQ_Device_Name or IP>"
      end
end

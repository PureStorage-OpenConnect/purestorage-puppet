Puppet::Type.newtype(:pure_host) do
  @doc = "It does CRUD operations for hosts on a Pure Storage flash array."
  
  apply_to_all
  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The name of the host."
    validate do |value|
      fail("host name can not be empty or null: #{value}") if value == "null" or value.strip.empty?
    end
  end
  
  newproperty(:iqnlist, :array_matching => :all) do
    desc "Host iqnlist"
  end

  newproperty(:wwnlist, :array_matching => :all) do
    desc "Host wwnlist"
  end

  newparam(:device_url) do
      desc "URL in the form of https://<user>:<passwd>@<FQ_Device_Name or IP>"
  end
end

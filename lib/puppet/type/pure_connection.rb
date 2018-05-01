Puppet::Type.newtype(:pure_connection) do
  @doc = "It does CRUD operations for Host-volume Connection on a Pure Storage flash array."

  validate do
    self.fail "host name and volume name are mandatory" if !self[:host_name] || !self[:volume_name]
  end

  apply_to_all
  ensurable

  newparam(:host_name) do
    desc "The name of the host. "
    isnamevar
    validate do |value|
      fail("host name: #{value} can not be empty or null") if value == "null" or value.strip.empty?
    end
  end
       
  newparam(:volume_name) do
    desc "The name of the volume."
    validate do |value|
      fail("volume name: #{value} can not be empty or null") if value == "null" or value.strip.empty?
    end
  end

  newparam(:device_url) do
    desc "URL in the form of https://<user>:<passwd>@<FQ_Device_Name or IP>"
  end
end

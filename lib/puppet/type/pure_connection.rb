Puppet::Type.newtype(:pure_connection) do
  @doc = "It does CRUD operations for Host-volume Connection on a Pure Storage flash array."

  validate do
    raise ArgumentError, "host name and volume name are mandatory" if value(:host_name).nil? || value(:volume_name).nil?
  end

  apply_to_all
  ensurable

  newparam(:host_name) do
    desc "The name of the host. "
    isnamevar

    munge do |v|
      v.to_s.strip
    end
  end
       
  newparam(:volume_name) do
    desc "The name of the volume."
    isnamevar

    munge do |v|
      v.to_s.strip
    end
  end

  newparam(:device_url) do
    desc "URL in the form of https://<user>:<passwd>@<FQ_Device_Name or IP>"
  end

  # Support host_name:volume_name format
  def self.title_patterns
    [
      [ %r{(^([^:]*)$)}m,
        [ [:host_name] ] ],
      [ %r{^(.*):(.*)$},
        [ [:host_name], [:volume_name] ]
      ]
    ]
  end

  # Require pure_host and pure_volume resources
  autorequire(:pure_host) do
    self[:host_name]
  end

  autorequire(:pure_volume) do
    self[:volume_name]
  end
end

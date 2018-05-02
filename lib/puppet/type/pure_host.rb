Puppet::Type.newtype(:pure_host) do
  @doc = "It does CRUD operations for hosts on a Pure Storage flash array."
  
  apply_to_all
  ensurable
  
  newparam(:name) do
    desc "The name of the host."
    isnamevar
  end
  
  newproperty(:iqnlist, :array_matching => :all) do
    desc "Host iqnlist"
    newvalue(%r{^\w+$})

    # Pretty output for arrays.
    def should_to_s(value)
      value.inspect
    end

    def to_s?(value)
      value.inspect
    end
  end

  newproperty(:wwnlist, :array_matching => :all) do
    desc "Host wwnlist"
    newvalue(%r{^\w+$})

    # Pretty output for arrays.
    def should_to_s(value)
      value.inspect
    end

    def to_s?(value)
      value.inspect
    end
  end

  newparam(:device_url) do
      desc "URL in the form of https://<user>:<passwd>@<FQ_Device_Name or IP>"
  end
end

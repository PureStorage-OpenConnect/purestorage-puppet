require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/pure/device'

describe Puppet::Util::NetworkDevice::Pure::Facts do

  let(:array_details) do
    {
      "array_name": "Pure01",
      "id": "de2d6151-ba43-4264-9e6f-430626c2959e",
      "revision": "201802091837+238a5fe",
      "version": "4.10.9"
    }
  end

  it "should get facts from array" do
    @transport = double(:pure_array)
    expect(@transport).to receive(:getRestCall).with('/array') {array_details}
    facts = Puppet::Util::NetworkDevice::Pure::Facts.new(@transport).retrieve
    expect(facts['vendor_id']).to eq('pure')
  end
end

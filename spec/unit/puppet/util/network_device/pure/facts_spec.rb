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

  let(:controller_details) do
    [
      {
        "status": "ready",
        "model": "FA-m10r2",
        "version": "4.10.9",
        "name": "CT0",
        "mode": "secondary"
      },
      {
        "status": "ready",
        "model": "FA-m10r2",
        "version": "4.10.9",
        "name": "CT1",
        "mode": "primary"
      }
    ]
  end

  before(:each) do
    @transport = double('transport')
    @facts = Puppet::Util::NetworkDevice::Pure::Facts.new(@transport)
  end

  it 'should have facts read-only' do
    expect(@facts.facts).to be_nil
    expect { @facts.facts = 'some new facts' }.to raise_error NoMethodError
  end

  it 'should have transport read-only' do
    expect(@facts.transport).to be @transport
    expect { @facts.transport = 'new transport' }.to raise_error NoMethodError
  end

  context '#initialize' do
    it 'should set transport readable' do
      transport = double('transport')
      facts = Puppet::Util::NetworkDevice::Pure::Facts.new(transport)
      expect(facts.transport).to be(transport)
    end
  end

  context '#retrieve' do
    it "should get facts from array" do
      allow(@transport).to receive(:getRestCall).with('/array').and_return(array_details)
      allow(@transport).to receive(:getRestCall).with('/array?controllers=true').and_return(controller_details)
      facts = @facts.retrieve
      expect(facts).to eq({
        'array_name'  => 'Pure01',
        'controllers' => controller_details,
        'vendor_id'   => 'pure',
        'version'     => '4.10.9'
      })
    end
  end
end

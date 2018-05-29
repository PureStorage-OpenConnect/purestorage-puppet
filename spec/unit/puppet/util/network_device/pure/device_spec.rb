require 'spec_helper'
require 'puppet/util/network_device/pure/device'
require 'yaml'

describe Puppet::Util::NetworkDevice::Pure::Device do

  context "when connecting to a new device" do
    describe 'with bad config' do
      it "should reject an invalid URL" do
        expect { described_class.new('pure01.example.com') }
          .to raise_error(ArgumentError, /invalid scheme/)
      end

      it "should reject a missing username" do
        expect { described_class.new('https://pure01.example.com') }
          .to raise_error(ArgumentError, 'no user specified')
      end

      it "should reject a missing password" do
        expect { described_class.new('https://admin@pure01.example.com') }
          .to raise_error(ArgumentError, 'no password specified')
      end

      it "should not accept plain http connections" do
        expect { described_class.new('http://admin:secret@pure01.example.com') }
          .to raise_error(ArgumentError, 'invalid scheme http. Must be https')
      end
    end

    describe 'with valid config' do
      before(:each) do
        @transport = double(:pure_array)
      end

      it "should connect to the specificed Pure array" do
        expect(PureStorageApi).to receive(:new).with('pure01.example.com', 'admin', 'secret', '1.6') { @transport }
        pure = described_class.new('https://admin:secret@pure01.example.com')
        expect(pure.api_version).to eq('1.6')
      end

      describe 'with an api_version provided' do
        it "should connect to the specificed api version" do
          expect(PureStorageApi).to receive(:new).with('pure01.example.com', 'admin', 'secret', '1.12') { @transport }
          pure = described_class.new('https://admin:secret@pure01.example.com/?api_version=1.12')
          expect(pure.api_version).to eq('1.12')
        end
      end
    end
  end

end

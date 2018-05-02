require 'spec_helper'

describe Puppet::Type.type(:pure_host) do
  context 'attributes' do
    [:name, :device_url].each do |parameter|
      describe parameter.to_s do
        it 'has a name attribute' do
          expect(described_class.attrclass(parameter)).not_to be_nil
        end

        it 'is a parameter' do
          expect(described_class.attrtype(parameter)).to eq(:param)
        end
      end
    end

    [:iqnlist, :wwnlist].each do |property|
      describe property.to_s do
        it 'has a name attribute' do
          expect(described_class.attrclass(property)).not_to be_nil
        end

        it 'is a property' do
          expect(described_class.attrtype(property)).to eq(:property)
        end
      end
    end

    it 'has name as namevar' do
      expect(described_class.key_attributes.sort).to eq([:name])
    end
  end

end

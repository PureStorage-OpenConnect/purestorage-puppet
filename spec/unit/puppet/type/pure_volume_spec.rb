require 'spec_helper'

describe Puppet::Type.type(:pure_volume) do
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

    [:size].each do |property|
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

  describe 'validation' do
    it 'fails validation without a size' do
      expect{described_class.new(title: 'volume')}
        .to raise_error(Puppet::Error, %r{size attribute is mandatory})
    end

    it 'fails validation with an invalid size' do
      expect{described_class.new(title: 'volume', size: '123456')}
        .to raise_error(Puppet::Error, %r{is not a valid volume size})
    end
  end

end

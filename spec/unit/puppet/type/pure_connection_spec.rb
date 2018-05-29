require 'spec_helper'

describe Puppet::Type.type(:pure_connection) do
  context 'attributes' do
    [:host_name, :volume_name].each do |parameter|
      describe parameter.to_s do
        it 'has a name attribute' do
          expect(described_class.attrclass(parameter)).not_to be_nil
        end

        it 'is a parameter' do
          expect(described_class.attrtype(parameter)).to eq(:param)
        end
      end
    end

    it 'has a device_url attribute' do
      expect(described_class.attrclass(:device_url)).not_to be_nil
    end

    it 'specifies device_url as a parameter' do
      expect(described_class.attrtype(:device_url)).to eq(:param)
    end

    it 'has host_name and volume_name as namevars' do
      expect(described_class.key_attributes.sort).to eq([:host_name, :volume_name])
    end
  end

  describe 'declaring the type' do
    it 'maps host_name:volume_name form the resource title to host_name' do
      type = described_class.new(title: 'foo:bar')
      expect(type[:host_name]).to eq('foo')
    end

    it 'maps host_name:volume_name form the resource title to volume_name' do
      type = described_class.new(title: 'foo:bar')
      expect(type[:volume_name]).to eq('bar')
    end

    it 'ignores title when host_name is declared' do
      type = described_class.new(title: 'foo/bar', host_name: 'tango', volume_name: 'delta')
      expect(type[:host_name]).to eq('tango')
    end
    it 'ignores title when volume_name is declared' do
      type = described_class.new(title: 'foo/bar', host_name: 'tango', volume_name: 'delta')
      expect(type[:volume_name]).to eq('delta')
    end
  end

  describe 'validation' do
    it 'fails validation without a volume_name' do
      expect{described_class.new(title: 'host')}
        .to raise_error(Puppet::Error, %r{host name and volume name are mandatory})
    end
  end

  context 'when autorequireing resources' do
    describe 'should autorequire pure_host resource' do
      pure_host = Puppet::Type.type(:pure_host).new(
        name: 'host01',
        ensure: :present
      )

      pure_conn = described_class.new(
        title: 'host01:vol01'
      )

      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource pure_host
      catalog.add_resource pure_conn
      req = pure_conn.autorequire

      it 'is equal' do
        expect(req.size).to eq(1)
      end
      it 'has matching source' do
        expect(req[0].source).to eq pure_host
      end
      it 'has matching target' do
        expect(req[0].target).to eq pure_conn
      end
    end

    describe 'should autorequire pure_volume resource' do
      pure_volume = Puppet::Type.type(:pure_volume).new(
        name: 'vol01',
        ensure: :present,
        size: '10G'
      )

      pure_conn = described_class.new(
        title: 'host01:vol01'
      )

      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource pure_volume
      catalog.add_resource pure_conn
      req = pure_conn.autorequire

      it 'is equal' do
        expect(req.size).to eq(1)
      end
      it 'has matching source' do
        expect(req[0].source).to eq pure_volume
      end
      it 'has matching target' do
        expect(req[0].target).to eq pure_conn
      end
    end
  end
end

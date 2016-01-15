require 'rails_helper'

describe Manifest do
  describe 'Validations' do
    it 'validates presence of manifest tracking number' do
      manifest = build(:manifest, content: { generator: {} })

      expect(manifest).to be_invalid
    end
  end

  describe '#uuid' do
    context 'db generates default v4 UUID' do
      it 'has valid uuid after insert' do
        manifest = create(:manifest)
        manifest.reload
        expect(manifest.uuid).to match(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/)
      end
    end
  end

  describe '#content_field' do
    context 'access json tree via dotted string' do
      it 'can find manifest tracking number' do
        manifest = create(:manifest)
        expect(manifest.content_field('generator.manifest_tracking_number')).to eq manifest.tracking_number
      end

      it "returns nil if field xpath does not exist" do
        manifest = create(:manifest)
        expect(manifest.content_field('foo.bar')).to eq nil
      end
    end
  end

  describe '#tracking_number' do
    context 'generator manifest tracking number is present' do
      it 'returns the generator manifest tracking number' do
        tracking_number = '12345'

        manifest = build(:manifest, content: { generator: { manifest_tracking_number: tracking_number } })

        expect(manifest.tracking_number).to eq tracking_number
      end

      it 'does not allow manifests with duplicate tracking number' do
        tracking_number = '12345'

        manifest = create(:manifest, content: { generator: { manifest_tracking_number: tracking_number } })
        expect {
          manifest_dup = create(:manifest, content: { generator: { manifest_tracking_number: tracking_number } })
        }.to raise_exception(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe '#find_by_uuid_or_tracking_number' do
    context 'find by either uuid or tracking_number' do
      it 'finds by uuid' do
        manifest = create(:manifest)
        expect(Manifest.find_by_uuid_or_tracking_number(manifest.uuid)).to eq manifest
      end

      it 'finds by tracking number' do
        manifest = create(:manifest)
        expect(Manifest.find_by_uuid_or_tracking_number(manifest.tracking_number)).to eq manifest
      end

      it 'returns nil when cannot find by either' do
        expect(Manifest.find_by_uuid_or_tracking_number('foo')).to eq nil
      end

      it 'raises exception when called as find_by_uuid_or_tracking_number! and not found' do
        expect {
          Manifest.find_by_uuid_or_tracking_number!('foo')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#generator_name' do
    context 'generator name is present' do
      it 'returns the generator name' do
        name = 'Test name'

        manifest = build(:manifest, content: { generator: { name: name } })

        expect(manifest.generator_name).to eq name
      end
    end

    context 'generator name is not present' do
      it 'returns an empty string' do
        manifest = build(:manifest, content: { generator: { name: nil } })

        expect(manifest.generator_name).to eq ''
      end
    end
  end
end

require 'rails_helper'

describe Manifest do
  describe 'Validations' do
    it 'validates presence of manifest tracking number' do
      manifest = build(:manifest, content: { generator: {} })

      expect(manifest).to be_invalid
    end

    it 'validates uniqueness of manifest tracking number' do
      manifest = create(:manifest)
      duplicate_manifest = build(
        :manifest,
        content: { generator: { manifest_tracking_number: manifest.tracking_number} }
      )

      expect(duplicate_manifest).to be_invalid
    end

    it 'does not validate uniqueness of manifest trackig number against itself' do
      manifest = create(:manifest)
      manifest.content['generator']['manifest_tracking_number'] = manifest.tracking_number

      expect(manifest).to be_valid
    end

    it 'validates format of manifest tracking number' do
      manifest = build(:manifest, content: { generator: { manifest_tracking_number: '123' } })

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
       tracking_number = '987654321ABC'

        manifest = create(:manifest, content: { generator: { manifest_tracking_number: tracking_number } })
        expect {
          manifest_dup = create(:manifest, content: { generator: { manifest_tracking_number: tracking_number } })
        }.to raise_exception(ActiveRecord::RecordInvalid)
      end

      it 'does not allow tracking number to change to non-unique' do
        manifest = create(:manifest)
        manifest2 = create(:manifest)
        manifest.content['generator']['manifest_tracking_number'] = manifest2.tracking_number

        expect {
          manifest.save!
        }.to raise_exception(ActiveRecord::RecordInvalid)
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
        }.to raise_error(ManifestNotFound)
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

  describe '#generator_mailing_address' do
    context 'generator_mailing_address is present' do
      it 'returns hash of generator_mailing_address' do
        manifest = build(:manifest, content: { generator: { mailing_address: { zip_code: '12345' } } } )

        expect(manifest.generator_mailing_address).to eq({ 'zip_code' => '12345' })
      end
    end

    context 'generator_mailing_address is absent' do
      it 'returns empty hash' do
        manifest = build(:manifest)

        expect(manifest.generator_mailing_address).to eq({})
      end
    end
  end

  describe '#is_public?' do
    context 'calculates public status' do
      it 'is true for older than 90 days' do
        manifest = create(:manifest)
        manifest.created_at = Time.current - 91.days.ago.to_f
        expect(manifest.is_public?).to eq true
      end

      it 'is false for newer than 90 days' do
        manifest = create(:manifest)
        expect(manifest.is_public?).to eq false
      end
    end
  end

  describe '#has_state?' do
    context 'any matching state field equals a match' do
      it 'matches all state_fields' do
        state = 'KS'
        Manifest.state_fields.each do |field|
          parts = field.split('.')
          content = {}
          parts.inject(content) do |h,k|
            h[k] = {}
            if k == parts.last
              h[k] = state
            end
            h[k]
          end
          manifest = build(:manifest, content: content)

          expect(manifest.has_state?(state)).to eq true
        end
      end
    end
  end
end

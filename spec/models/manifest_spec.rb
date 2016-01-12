require 'rails_helper'
describe Manifest do
  describe '#tracking_number' do
    context 'generator manifest tracking number is present' do
      it 'returns the generator manifest tracking number' do
        tracking_number = '12345'

        manifest = create(:manifest, content: { generator: { manifest_tracking_number: tracking_number } })

        expect(manifest.tracking_number).to eq tracking_number
      end
    end

    context 'generator manifest tracking number is not present' do
      it 'returns an empty string' do
        manifest = create(:manifest, content: { generator: { manifest_tracking_number: nil } })

        expect(manifest.tracking_number).to eq ""
      end
    end
  end

  describe '#generator_name' do
    context 'generator name is present' do
      it 'returns the generator name' do
        name = 'Test name'

        manifest = create(:manifest, content: { generator: { name: name } })

        expect(manifest.generator_name).to eq name
      end
    end

    context 'generator name is not present' do
      it 'returns an empty string' do
        manifest = create(:manifest, content: { generator: { name: nil } })

        expect(manifest.generator_name).to eq ""
      end
    end
  end
end

require 'rails_helper'

describe 'API request spec' do
  describe 'post /api/v0/manifests/:manifest_id/signature' do
    context 'sign by manifest id' do
      it 'creates retrieves and resaves a manifest with document id' do
        manifest = create(:manifest)
        cdx_manifest = double('cdx manifest', sign: { document_id: 44 })
        expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        post "/api/v0/manifests/#{manifest.uuid}/signature",
          { activity_id: 22 }.to_json,
          set_headers

        manifest.reload
        expect(manifest.document_id).to eq('44')
        expect(manifest.activity_id).to eq('22')
        expect(manifest.signed_at).to_not eq(nil)
      end

      it 'will not update the document/activity id if the CDX request does not include the right key' do
        manifest = create(:manifest)
        cdx_manifest = double('cdx manifest', sign: { foo: 'bar' })
        expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        post "/api/v0/manifests/#{manifest.uuid}/signature",
          { activity_id: 22 }.to_json,
          set_headers

        manifest.reload
        expect(manifest.document_id).to eq(nil)
        expect(manifest.activity_id).to eq(nil)
        expect(manifest.signed_at).to eq(nil)
      end
    end

    context 'sign by manifest tracking number' do
      it 'creates retrieves and resaves a manifest with document id' do
        manifest_tracking_number = "AAABB1234"
        manifest = Manifest.create(
          content: {
            generator: {
              name: 'test',
              manifest_tracking_number: manifest_tracking_number
            }
          }
        )
        cdx_manifest = double('cdx manifest', sign: { document_id: 44 })
        expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        post "/api/v0/manifests/#{manifest_tracking_number}/signature",
          { activity_id: 22 }.to_json,
          set_headers

        manifest.reload
        expect(manifest.document_id).to eq('44')
        expect(manifest.activity_id).to eq('22')
        expect(manifest.signed_at).to_not eq(nil)
      end
    end
  end
end

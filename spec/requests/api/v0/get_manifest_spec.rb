require 'rails_helper'

describe 'GET Manifest' do
  describe 'GET manifest' do
    context 'id param' do
      it 'return the manifest as json' do
        manifest = Manifest.create(activity_id: 1, document_id: 2, content: { hello: 'world' })

        get "/api/v0/manifest?id=#{manifest.id}",
          set_headers

        expect(response).to match_response_schema("manifest")
      end

      it 'sends a 404 when the manifest cannot be found' do
        get '/api/v0/manifest?id=9940010140808v9019',
          set_headers

        expect(response.status).to eq(404)
      end
    end

    context 'tracking number param' do
      it 'return the manifest as json' do
        manifest_tracking_number = 'TEST_NUMBER'
        Manifest.create(activity_id: 1, document_id: 2, content: {generator: {name: "test", "manifest_tracking_number": manifest_tracking_number}})

        get "/api/v0/manifest?tracking_number=#{manifest_tracking_number}",
          set_headers

        expect(response).to match_response_schema('manifest')
      end

      it 'sends a 404 when the manifest cannot be found' do
        get "/api/v0/manifest?tracking_number=9940010140808v9019"

        expect(response.status).to eq(404)
      end
    end
  end
end

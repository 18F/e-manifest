require 'rails_helper'

describe 'GET Manifest' do
  describe 'GET manifest' do
    context 'id param' do
      it 'return the manifest as json' do
        manifest = Manifest.create(activity_id: 1, document_id: 2, content: { hello: 'world' })
        manifest.reload

        get "/api/v0/manifests/#{manifest.uuid}",
          set_headers

        expect(response.status).to eq(200)
        expect(response).to match_response_schema("get-manifest")
      end

      it 'sends a 404 when the manifest cannot be found' do
        get "/api/v0/manifests/9940010140808v9019",
          set_headers

        expect(response.status).to eq(404)
      end
    end
  end
end

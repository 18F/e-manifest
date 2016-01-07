require_relative "../../../request_spec_helper"

describe "GET Manifest" do
  describe 'GET manifest/id/:manifestid' do
    it 'return the manifest as json' do
      manifest = Manifest.create(activity_id: 1, document_id: 2, content: { hello: 'world' })

      response = get "/api/0.1/manifest/id/#{manifest.id}"

      expect(response).to match_response_schema("manifest")
    end

    it 'sends a 404 when the manifest cannot be found' do
      get '/api/0.1/manifest/id/9940010140808v9019'

      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET manifest/:manifest_tracking_number' do
    it 'return the manifest as json' do
      manifest_tracking_number = "TEST_NUMBER"
      Manifest.create(activity_id: 1, document_id: 2, content: {generator: {name: "test", "manifest_tracking_number": manifest_tracking_number}})

      response = get "/api/0.1/manifest/#{manifest_tracking_number}"

      expect(response).to match_response_schema('manifest')
    end

    it 'sends a 404 when the manifest cannot be found' do
      get "/api/0.1/manifest/id/9940010140808v9019"

      expect(last_response.status).to eq(404)
    end
  end
end

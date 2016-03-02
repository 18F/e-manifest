require 'rails_helper'

describe 'GET Manifest' do
  describe 'GET manifest' do
    context 'id param' do
      it 'return the manifest as json' do
        user_session = mock_authenticated_session
        manifest = create(:manifest, activity_id: 1, document_id: 2, user: user_session.user)

        get "/api/v0/manifests/#{manifest.uuid}", nil, set_headers

        expect(response.status).to eq(200)
        expect(response).to match_response_schema("get-manifest")
      end

      it 'finds by manifest tracking number' do
        user_session = mock_authenticated_session
        manifest = create(:manifest, activity_id: 1, document_id: 2, user: user_session.user)

        get "/api/v0/manifests/#{manifest.tracking_number}", nil, set_headers

        expect(response.status).to eq(200)
        expect(response).to match_response_schema("get-manifest")
      end

      it 'sends a 404 when the manifest cannot be found' do
        get "/api/v0/manifests/9940010140808v9019", nil, set_headers

        expect(response.status).to eq(404)
      end
    end

    context 'authorization' do
      it 'allows anyone to view public manifest' do
        manifest = create(:manifest, created_at: 100.days.ago)

        get "/api/v0/manifests/#{manifest.uuid}", nil, set_headers

        expect(response.status).to eq(200)
      end

      it 'allows authenticated user to see their own manifest' do
        user_session = mock_authenticated_session
        manifest = create(:manifest, user: user_session.user)

        get "/api/v0/manifests/#{manifest.uuid}", nil, set_headers

        expect(response.status).to eq(200)
      end

      it 'disallows anon user from seeing private manifest' do
        manifest = create(:manifest)

        get "/api/v0/manifests/#{manifest.uuid}", nil, set_headers

        expect(response.status).to eq(403)
      end

      it 'disallows authenticated user from seeing manifest created by someone else' do
        user_session = mock_authenticated_session
        manifest = create(:manifest, user: user_session.user)

        diff_user_session = mock_authenticated_session

        get "/api/v0/manifests/#{manifest.uuid}", nil, set_headers

        expect(response.status).to eq(403)
      end
    end
  end
end

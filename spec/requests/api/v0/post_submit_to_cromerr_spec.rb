require 'rails_helper'

describe 'post /api/v0/manifests/:manifest_id/submit_to_cromerr' do
  context 'submits successfully' do
    context 'submit by manifest id' do
      it 'creates retrieves and transmits a manifest' do
        session = mock_cdx_submit_authorize_pass
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)
        cdx_response = mock_cdx_submit_response

        submit_payload = {
          answer: "Tester",
          question_id: question_id,
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.uuid}/submit_to_cromerr",
          submit_payload.to_json,
          set_headers

        expect(response.status).to eq(200)
        expect(parsed_response['transaction_id']).to eq(mock_cdx_submit_response[:transaction_id])
      end
    end
    context 'submits by manifest tracking number' do
      it 'creates retrieves and transmits a manifest' do
        session = mock_cdx_submit_authorize_pass
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)
        cdx_response = mock_cdx_submit_response

        submit_payload = {
          answer: "Tester",
          question_id: question_id,
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.tracking_number}/submit_to_cromerr",
          submit_payload.to_json,
          set_headers

        expect(response.status).to eq(200)
        expect(parsed_response['transaction_id']).to eq(mock_cdx_submit_response[:transaction_id])
      end
    end
  end
  
  context 'submission fails' do
    context 'submits by manifest id' do
      it 'submits malformed request' do
        session = mock_cdx_submit_authorize_pass
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)

        submit_payload = {
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.uuid}/submit_to_cromerr",
             submit_payload.to_json,
             set_headers

        expect(response.status).to eq(422)
      end
      it 'gets failure from CDX' do
        session = mock_cdx_submit_authorize_fails
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)

        submit_payload = {
          answer: "Tester",
          question_id: question_id,
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.uuid}/submit_to_cromerr",
             submit_payload.to_json,
             set_headers

        expect(response.status).to eq(422)
      end

    end
    context 'user lacks signer/submitter role' do
      it 'returns 403 response' do
        session = mock_cdx_submit_authorize_pass
        manifest = create(:manifest, user: session.user)

        submit_payload = {
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.uuid}/submit_to_cromerr",
          submit_payload.to_json,
          set_headers

        expect(response.status).to eq 403
      end
    end
  end

  private

  def question_id
    "123abc"
  end

  def token
    "abcedf123"
  end

  def user_id
    "fakeUserId"
  end
  
  def parsed_response
    JSON.parse(response.body)
  end
end

require 'rails_helper'

describe 'post /api/v0/manifests/:manifest_id/signature' do
  context 'submits successfully' do
    context 'submit by manifest id' do
      it 'creates retrieves and resaves a manifest with transaction id' do
        session = mock_user_signature_authorize_pass
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)
        cdx_response = mock_cdx_signature_response

        signature_payload = {
          activity_id: cdx_response[:activity_id],
          answer: "Tester",
          question_id: question_id,
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.uuid}/signature",
          signature_payload.to_json,
          set_headers

        manifest.reload
        expect(manifest.activity_id).to eq(signature_payload[:activity_id])
        expect(manifest.transaction_id).to eq(mock_cdx_signature_response[:transaction_id])
        expect(manifest.submitted_at).not_to eq nil
      end
    end

    context 'submit by manifest tracking number' do
      it 'creates retrieves and resaves a manifest with transaction id' do
        session = mock_user_signature_authorize_pass
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)
        cdx_response = mock_cdx_signature_response

        signature_payload = {
          activity_id: cdx_response[:activity_id],
          answer: "Tester",
          question_id: question_id,
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.tracking_number}/signature",
          signature_payload.to_json,
          set_headers

        manifest.reload
        expect(manifest.activity_id).to eq(signature_payload[:activity_id])
        expect(manifest.transaction_id).to eq(mock_cdx_signature_response[:transaction_id])
        expect(manifest.submitted_at).not_to eq nil
      end
    end
  end

  context 'sign failure' do
    context 'user lacks submitter role' do
      it 'returns 403 response' do
        session = mock_user_signature_authorize_pass
        session.user.user_org_roles.map(&:destroy!)
        manifest = create(:manifest, user: session.user)
        cdx_response = mock_cdx_signature_response

        signature_payload = {
          activity_id: cdx_response[:activity_id],
          answer: "Tester",
          question_id: question_id,
          token: token,
          user_id: user_id,
        }

        post "/api/v0/manifests/#{manifest.uuid}/signature",
          signature_payload.to_json,
          set_headers

        expect(response.status).to eq 403
      end
    end

    context 'bad token sent with request' do
      it 'returns a helpful error message' do
        session = mock_user_signature_authorize_fail
        profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
        profile_syncer.run

        manifest = create(:manifest, user: session.user)

        post "/api/v0/manifests/#{manifest.tracking_number}/signature",
          { token: 'fakeToken' }.to_json,
          set_headers

        manifest.reload
        expect(response.status).to eq 422
        expect(manifest.submitted_at).to eq nil
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
end

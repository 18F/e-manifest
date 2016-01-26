require 'rails_helper'

describe 'post /api/v0/manifests/:manifest_id/signature' do
  context 'signs successfully' do
    context 'sign by manifest id' do
      it 'creates retrieves and resaves a manifest with document id' do
        VCR.use_cassette('api_sign_success') do
          manifest = create(:manifest)
          document_id_from_fixture = "fakeDocumentId"

          json = {
            activity_id: activity_id,
            answer: "Tester",
            question_id: question_id,
            token: token,
            user_id: user_id,
          }

          post "/api/v0/manifests/#{manifest.uuid}/signature",
            json.to_json,
            set_headers

          manifest.reload
          expect(manifest.activity_id).to eq(activity_id)
          expect(manifest.document_id).to eq(document_id_from_fixture)
          expect(manifest.signed_at).not_to eq nil
        end
      end
    end

    context 'sign by manifest tracking number' do
      it 'creates retrieves and resaves a manifest with document id' do
        VCR.use_cassette('api_sign_success') do
          manifest = create(:manifest)
          document_id_from_fixture = "fakeDocumentId"
          json = {
            activity_id: activity_id,
            answer: "Test",
            question_id: question_id,
            token: token,
            user_id: user_id,
          }

          post "/api/v0/manifests/#{manifest.tracking_number}/signature",
            json.to_json,
            set_headers

          manifest.reload
          expect(manifest.activity_id).to eq(activity_id)
          expect(manifest.document_id).to eq(document_id_from_fixture)
          expect(manifest.signed_at).not_to eq nil
        end
      end
    end
  end

  context 'sign failure' do
    context 'bad tken sent with request' do
      it 'returns a helpful error message' do
        VCR.use_cassette('user_auth_failure') do
          manifest = create(:manifest)

          post "/api/v0/manifests/#{manifest.tracking_number}/signature",
            { token: 'fakeToken' }.to_json
            set_headers

            manifest.reload
            expect(response.status).to eq 422
            expect(manifest.signed_at).to eq nil
        end
      end
    end
  end

  private

  def auth
    @_auth ||= CDX::Authenticator.new({ user_id: user_id, password: "fakePassword" }).perform
  end

  def token
    auth[:token]
  end

  def question_id
    auth[:question][:question_id]
  end

  def question
    auth[:question][:question_text]
  end

  def user_id
    "fakeUserId"
  end

  def activity_id
    "fakeActivityId"
  end
end

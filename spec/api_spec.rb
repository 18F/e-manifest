require_relative "request_spec_helper"

RSpec.describe 'API request spec' do
  # NOTE: Savon does some crap internally that prevents webmock from working
  # correctly. It is a bad practice to mock your own classes in request specs, but
  # better than nothing!

  describe 'post /api/user/authenticate' do
    let(:user_credentials) {
      {'userId' => 'userId', 'password' => 'password'}
    }

    let(:authenticator) {
      double('authenticator', perform: {it: 'worked'})
    }

    it 'posting an authentication' do
      expect(CDX::Authenticator).to receive(:new)
        .with(user_credentials)
        .and_return(authenticator)

      send_json(:post, '/api/user/authenticate', user_credentials)

      expect(last_response.ok?).to eq(true)
      expect(last_response.body).to eq({it: 'worked'}.to_json)
    end
  end

  describe 'post /api/manifest/sign' do
    it 'creates retrieves and resaves a manifest with document id' do
      manifest = Manifest.create(content: {activityId: 22})
      cdx_manifest = double('cdx manifest', sign: {documentId: 44})
      expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

      send_json(:post, '/api/manifest/sign', {id: manifest.id, activityId: 22})

      manifest.reload
      expect(manifest.document_id).to eq('44')
      expect(manifest.activity_id).to eq('22')
    end
  end
end



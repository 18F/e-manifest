require_relative "request_spec_helper"

RSpec.describe 'API request spec' do
  before do
    Manifest.delete_all
  end

  describe '/api/manifest/submit/:manifest_tracking_number' do
    it 'creates a new manefist' do
      expect {
        send_json(:post, '/api/manifest/submit/30221', {hello: 'world'})
      }.to change { Manifest.count }.by(1)
      manifest = Manifest.last
      expect(manifest.content).to eq({'hello' => 'world'})
    end
  end

  describe '/api/manifest/id/:manifestid' do
    it 'return the manifest as json' do
      manifest = Manifest.create(activity_id: 1, document_id: 2, content: {hello: 'world'})
      get "/api/manifest/id/#{manifest.id}"
      expect(last_response.body).to eq(manifest.to_json)
    end
  end

  describe '/api/manifest/search' do
    it 'returns all manifests as json' do
      (1..3).each { |n| Manifest.create(content: {number: n}) }
      get '/api/manifest/search'
      expect(last_response.body).to eq(Manifest.all.to_json)
    end
  end

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
      manifest = Manifest.create(content: {})
      cdx_manifest = double('cdx manifest', sign: {documentId: 44})
      expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

      send_json(:post, '/api/manifest/sign', {id: manifest.id, activityId: 22})

      manifest.reload
      expect(manifest.document_id).to eq('44')
      expect(manifest.activity_id).to eq('22')
    end

    it 'will not update the document/activity id if the CDX request does not include the right key' do
      manifest = Manifest.create(content: {})
      cdx_manifest = double('cdx manifest', sign: {foo: 'bar'})
      expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

      send_json(:post, '/api/manifest/sign', {id: manifest.id, activityId: 22})

      manifest.reload
      expect(manifest.document_id).to eq(nil)
      expect(manifest.activity_id).to eq(nil)
    end
  end
end



require_relative "support/request_spec_helper"

RSpec.describe 'API request spec' do
  describe '/api/0.1/manifest/submit/:manifest_tracking_number' do
    it 'creates a new manifest' do
      expect {
        send_json(:post, '/api/0.1/manifest/submit/30221', {hello: 'world'})
      }.to change { Manifest.count }.by(1)
      manifest = Manifest.last
      expect(manifest.content).to eq({'hello' => 'world'})
      expect(last_response.headers["Location"]).to eq("/api/0.1/manifest/id/#{manifest.id}")
    end
  end

  describe '/api/0.1/manifest/id/:manifestid' do
    it 'return the manifest as json' do
      manifest = Manifest.create(activity_id: 1, document_id: 2, content: {hello: 'world'})
      get "/api/0.1/manifest/id/#{manifest.id}"
      expect(last_response.body).to eq(manifest.to_json)
    end

    it 'sends a 404 when the manifest cannot be found' do
      get "/api/0.1/manifest/id/9940010140808v9019"
      expect(last_response.status).to eq(404)
    end
  end

  describe '/api/0.1/manifest/:manifest_tracking_number' do
    it 'return the manifest as json' do
      manifest_tracking_number = "TEST_NUMBER"
      manifest = Manifest.create(activity_id: 1, document_id: 2, content: {generator: {name: "test", "manifest_tracking_number": manifest_tracking_number}})
      get "/api/0.1/manifest/#{manifest_tracking_number}"
      expect(last_response.body).to eq(manifest.to_json)
    end

    it 'sends a 404 when the manifest cannot be found' do
      get "/api/0.1/manifest/id/9940010140808v9019"
      expect(last_response.status).to eq(404)
    end
  end

  describe 'PATCH /api/0.1/manifest/id/:manifestid' do
    it 'updates removes and adds fields to a manifest' do
      patch_command = [{"op": "replace", "path": "/hello", "value": "people"}, {"op": "add", "path": "/newitem", "value": "beta"},{"op": "remove", "path": "/foo/1"},{"op": "replace", "path": "/nested/something", "value": "ok"}]
      manifest = Manifest.create(activity_id: 2, document_id: 3, content: {hello: 'world', foo: ['bar', 'baz', 'quux'], nested: { something: 'good' } })
      send_json(:patch, "/api/0.1/manifest/id/#{manifest.id}", patch_command)
      updatedManifest = Manifest.find(manifest.id)

      expected_content_hash = {'hello' => 'people', 'newitem' => 'beta', 'foo' => ['bar', 'quux'], 'nested' => { 'something' => 'ok' }}
      parsed_response = JSON.parse(last_response.body)
      parsed_content = JSON.parse(parsed_response["content"])
      
      expect(updatedManifest.content).to eq(expected_content_hash)
      expect(parsed_content).to eq(expected_content_hash)
      expect(parsed_response["id"]).to eq(manifest.id)
    end
  end
                                 
  describe 'PATCH /api/0.1/manifest/:manifest_tracking_number' do
    it 'updates removes and adds fields to a manifest' do
      manifest_tracking_number = "TEST_NUMBER"
      patch_command = [{"op": "replace", "path": "/hello", "value": "people"}, {"op": "add", "path": "/newitem", "value": "beta"},{"op": "remove", "path": "/foo/1"},{"op": "replace", "path": "/nested/something", "value": "ok"}]

      manifest = Manifest.create(activity_id: 2, document_id: 3, content: {hello: 'world', foo: ['bar', 'baz', 'quux'], nested: { something: 'good' }, generator: {name: "test", "manifest_tracking_number": manifest_tracking_number} })
      send_json(:patch, "/api/0.1/manifest/#{manifest_tracking_number}", patch_command)
      updatedManifest = Manifest.find(manifest.id)

      expected_content_hash = {'hello' => 'people', 'newitem' => 'beta', 'foo' => ['bar', 'quux'], 'nested' => { 'something' => 'ok' }, 'generator' => { "name" => "test", "manifest_tracking_number" => manifest_tracking_number}}
      parsed_response = JSON.parse(last_response.body)
      parsed_content = JSON.parse(parsed_response["content"])
      
      expect(updatedManifest.content).to eq(expected_content_hash)
      expect(parsed_content).to eq(expected_content_hash)
      expect(parsed_response["id"]).to eq(manifest.id)
    end
  end
                                 

  # There's no nice way to test an API that simply pulls content out
  # of the jekyll-generated public directory. We cannot assume the
  # file exists when we run the test in development/CI and we cannot
  # pull the file from a non-generated public directory in production.
  #
  # Will begrudgingly move on to other things for now.
  #
  # describe '/api/0.1/method_code' do
  #  it 'returns the static json data for all method codes' do
  #    method_code_json = IO.read(File.dirname(__FILE__) + "/../_static/api-data/method-codes.json")
  #    get "/api/0.1/method_code"
  #    expect(last_response.body).to eq(method_code_json)
  #  end
  #end
  
  # NOTE: Savon does some crap internally that prevents webmock from working
  # correctly. It is a bad practice to mock your own classes in request specs, but
  # better than nothing!

  describe 'post /api/0.1/user/authenticate' do
    let(:user_credentials) {
      {'user_id' => 'userId', 'password' => 'password'}
    }

    let(:authenticator) {
      double('authenticator', perform: {it: 'worked', token: 'server'})
    }

    it 'posting an authentication and not exposing the authentication token' do
      expect(CDX::Authenticator).to receive(:new)
        .with(user_credentials)
        .and_return(authenticator)

      send_json(:post, '/api/0.1/user/authenticate', user_credentials)

      session_id = last_request.session.id
      expect(last_response.ok?).to eq(true)
      expect(last_response.body).to eq({it: 'worked', token: session_id}.to_json)
    end
  end

  describe 'post /api/0.1/manifest/sign' do
    it 'creates retrieves and resaves a manifest with document id' do
      manifest = Manifest.create(content: {})
      cdx_manifest = double('cdx manifest', sign: {document_id: 44})
      expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

      send_json(:post, '/api/0.1/manifest/sign', {id: manifest.id, activity_id: 22})

      manifest.reload
      expect(manifest.document_id).to eq('44')
      expect(manifest.activity_id).to eq('22')
    end

    it 'will not update the document/activity id if the CDX request does not include the right key' do
      manifest = Manifest.create(content: {})
      cdx_manifest = double('cdx manifest', sign: {foo: 'bar'})
      expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

      send_json(:post, '/api/0.1/manifest/sign', {id: manifest.id, activity_id: 22})

      manifest.reload
      expect(manifest.document_id).to eq(nil)
      expect(manifest.activity_id).to eq(nil)
    end
  end

  describe 'post /api/0.1/manifest/signByTrackingNumber' do
    it 'creates retrieves and resaves a manifest with document id' do
      manifest_tracking_number = "AAABB1234"
      manifest = Manifest.create(content: {generator: {name: "test", "manifest_tracking_number": manifest_tracking_number}})
      cdx_manifest = double('cdx manifest', sign: {document_id: 44})
      expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

      send_json(:post, '/api/0.1/manifest/signByTrackingNumber', {manifest_tracking_number: manifest_tracking_number, activity_id: 22})

      manifest.reload
      expect(manifest.document_id).to eq('44')
      expect(manifest.activity_id).to eq('22')
    end
  end
end



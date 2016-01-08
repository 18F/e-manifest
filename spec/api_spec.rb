require_relative "support/request_spec_helper"

RSpec.describe 'API request spec' do
  describe 'PATCH /api/v1/manifest/id/:manifestid' do
    it 'updates removes and adds fields to a manifest' do
      patch_command = [{"op": "replace", "path": "/hello", "value": "people"}, {"op": "add", "path": "/newitem", "value": "beta"},{"op": "remove", "path": "/foo/1"},{"op": "replace", "path": "/nested/something", "value": "ok"}]
      manifest = Manifest.create(activity_id: 2, document_id: 3, content: {hello: 'world', foo: ['bar', 'baz', 'quux'], nested: { something: 'good' } })
      send_json(:patch, "/api/v1/manifest/id/#{manifest.id}", patch_command)
      updatedManifest = Manifest.find(manifest.id)

      send_json(:patch, "/api/v1/manifests?id=#{manifest.id}", patch_command)

      updatedManifest = Manifest.find(manifest.id)

      expected_content_hash = {'hello' => 'people', 'newitem' => 'beta', 'foo' => ['bar', 'quux'], 'nested' => { 'something' => 'ok' }}
      parsed_response = JSON.parse(last_response.body)
      parsed_content = JSON.parse(parsed_response["content"])

      expect(updatedManifest.content).to eq(expected_content_hash)
      expect(parsed_content).to eq(expected_content_hash)
      expect(parsed_response["id"]).to eq(manifest.id)
    end
  end

  context 'finds manifest via tracking number param' do
      it 'updates removes and adds fields to a manifest' do
        manifest_tracking_number = "TEST_NUMBER"
        patch_command = [{"op": "replace", "path": "/hello", "value": "people"}, {"op": "add", "path": "/newitem", "value": "beta"},{"op": "remove", "path": "/foo/1"},{"op": "replace", "path": "/nested/something", "value": "ok"}]

        manifest = Manifest.create(activity_id: 2, document_id: 3, content: {hello: 'world', foo: ['bar', 'baz', 'quux'], nested: { something: 'good' }, generator: {name: "test", "manifest_tracking_number": manifest_tracking_number} })

        send_json(:patch, "/api/v1/manifests?tracking_number=#{manifest_tracking_number}", patch_command)

        updatedManifest = Manifest.find(manifest.id)

        expected_content_hash = {'hello' => 'people', 'newitem' => 'beta', 'foo' => ['bar', 'quux'], 'nested' => { 'something' => 'ok' }, 'generator' => { "name" => "test", "manifest_tracking_number" => manifest_tracking_number}}
        parsed_response = JSON.parse(last_response.body)
        parsed_content = JSON.parse(parsed_response["content"])

        expect(updatedManifest.content).to eq(expected_content_hash)
        expect(parsed_content).to eq(expected_content_hash)
        expect(parsed_response["id"]).to eq(manifest.id)
      end
    end
  end

  describe 'post /api/v1/tokens' do
    let(:user_credentials) {
      { 'user_id' => 'userId', 'password' => 'password' }
    }

    let(:authenticator) {
      double('authenticator', perform: { it: 'worked', token: 'server' })
    }

    it 'posting a token and not exposing the authentication token' do
      expect(CDX::Authenticator).to receive(:new)
        .with(user_credentials)
        .and_return(authenticator)

      send_json(:post, '/api/v1/tokens', user_credentials)

      session_id = last_request.session.id
      expect(last_response.ok?).to eq(true)
      expect(last_response.body).to eq({it: 'worked', token: session_id}.to_json)
    end
  end

  describe 'post /api/v1/manifests/:manifest_id/signature' do
    context 'sign by manifest id' do
      it 'creates retrieves and resaves a manifest with document id' do
        manifest = Manifest.create(content: {})
        cdx_manifest = double('cdx manifest', sign: { document_id: 44 })
        expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        send_json(:post, "/api/v1/manifests/#{manifest.id}/signature", { activity_id: 22 })

        manifest.reload
        expect(manifest.document_id).to eq('44')
        expect(manifest.activity_id).to eq('22')
      end

      it 'will not update the document/activity id if the CDX request does not include the right key' do
        manifest = Manifest.create(content: {})
        cdx_manifest = double('cdx manifest', sign: { foo: 'bar' })
        expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        send_json(:post, "/api/v1/manifests/#{manifest.id}/signature", { activity_id: 22 })

        manifest.reload
        expect(manifest.document_id).to eq(nil)
        expect(manifest.activity_id).to eq(nil)
      end
    end

    context 'sign by manifest tracking number' do
      it 'creates retrieves and resaves a manifest with document id' do
        manifest_tracking_number = "AAABB1234"
        manifest = Manifest.create(
          content: {
            generator: {
              name: 'test',
              manifest_tracking_number: manifest_tracking_number
            }
          }
        )
        cdx_manifest = double('cdx manifest', sign: { document_id: 44 })
        expect(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        send_json(:post, "/api/v1/manifests/#{manifest_tracking_number}/signature", { activity_id: 22 })

        manifest.reload
        expect(manifest.document_id).to eq('44')
        expect(manifest.activity_id).to eq('22')
      end
    end
  end
end

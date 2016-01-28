require 'rails_helper'

describe 'PATCH Manifest' do
  describe 'PATCH manifest' do
    context 'finds manifest with id param' do
      it 'updates removes and adds fields to a manifest by uuid' do
        user_session = mock_authenticated_session
        manifest_tracking_number = '987654321ABC'
        patch_command = [{"op": "replace", "path": "/hello", "value": "people"}, {"op": "add", "path": "/newitem", "value": "beta"},{"op": "remove", "path": "/foo/1"},{"op": "replace", "path": "/nested/something", "value": "ok"}]
        manifest = create(
          :manifest,
          activity_id: 2,
          document_id: 3,
          content: {
            generator: { manifest_tracking_number: manifest_tracking_number },
            hello: 'world',
            foo: ['bar', 'baz', 'quux'],
            nested: { something: 'good' }
          },
          user: user_session.user
        )

        patch "/api/v0/manifests/#{manifest.uuid}",
          patch_command.to_json,
          set_headers

        updated_manifest = Manifest.find(manifest.id)

        expected_content_hash = {
          'hello' => 'people',
          'newitem' => 'beta',
          'foo' => ['bar', 'quux'],
          'nested' => { 'something' => 'ok' },
          'generator' => { 'manifest_tracking_number' => manifest_tracking_number }
        }

        parsed_response = JSON.parse(response.body)
        parsed_content = JSON.parse(parsed_response["content"])

        expect(updated_manifest.content).to eq(expected_content_hash)
        expect(parsed_content).to eq(expected_content_hash)
        expect(parsed_response["id"]).to eq(manifest.uuid)
      end

      it 'updates removes and adds fields to a manifest by tracking number' do
        user_session = mock_authenticated_session
        manifest_tracking_number = '987654321ABC'
        patch_command = [{"op": "replace", "path": "/hello", "value": "people"}, {"op": "add", "path": "/newitem", "value": "beta"},{"op": "remove", "path": "/foo/1"},{"op": "replace", "path": "/nested/something", "value": "ok"}]
        manifest = create(
          :manifest,
          activity_id: 2,
          document_id: 3,
          content: {
            generator: { manifest_tracking_number: manifest_tracking_number },
            hello: 'world',
            foo: ['bar', 'baz', 'quux'],
            nested: { something: 'good' }
          },
          user: user_session.user
        )

        patch "/api/v0/manifests/#{manifest.tracking_number}",
          patch_command.to_json,
          set_headers

        updated_manifest = Manifest.find(manifest.id)

        expected_content_hash = {
          'hello' => 'people',
          'newitem' => 'beta',
          'foo' => ['bar', 'quux'],
          'nested' => { 'something' => 'ok' },
          'generator' => { 'manifest_tracking_number' => manifest_tracking_number }
        }

        parsed_response = JSON.parse(response.body)
        parsed_content = JSON.parse(parsed_response["content"])

        expect(updated_manifest.content).to eq(expected_content_hash)
        expect(parsed_content).to eq(expected_content_hash)
        expect(parsed_response["id"]).to eq(manifest.uuid)
      end
    end

    context 'authorization' do
      it 'disallows updating when not authenticated' do
        manifest = create(:manifest)
        patch "/api/v0/manifests/#{manifest.tracking_number}",
          [{op: 'replace', path: '/generator/manifest_tracking_number', value: '123456789xyz' }].to_json,
          set_headers

        expect(response.status).to eq(403)
      end

      it 'disallows updating when created by someone else' do
        manifest = create(:manifest)
        mock_authenticated_session
        patch "/api/v0/manifests/#{manifest.tracking_number}",
          [{op: 'replace', path: '/generator/manifest_tracking_number', value: '123456789xyz' }].to_json,
          set_headers

        expect(response.status).to eq(403)
      end
    end
  end
end

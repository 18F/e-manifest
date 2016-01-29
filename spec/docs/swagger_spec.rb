require 'rails_helper'
include JsonSchemaSpecHelper
include ExampleJsonHelper

describe 'Swagger docs', type: :apivore, order: :defined, elasticsearch: true do
  before(:all) do
    register_schemas_by_uri
  end

  subject { Apivore::SwaggerChecker.instance_for('/api-documentation/swagger.json') }

  context 'has valid paths' do
    before(:each) do
      @current_session = mock_authenticated_session
    end

    it do
      expect(subject).to validate(:get, '/manifests/{id}', 200, params.merge(header_params))
    end
    it do
      expect(subject).to validate(:get, '/manifests/{id}', 404, unknown_manifest_params.merge(header_params))
    end
    it do
      expect(subject).to validate(
        :post, '/manifests', 201, { '_data' => manifest_as_json.to_json }.merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :post, '/manifests', 422, { '_data' => { invalid_json: true }.to_json }.merge(header_params)
      )
    end
    it do
      manifest.content = manifest_as_json
      manifest.save!
      expect(subject).to validate(
        :patch, '/manifests/{id}', 200, params.merge(patch_params).merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :patch, '/manifests/{id}', 404, unknown_manifest_params.merge(patch_params).merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :get, '/manifests/search', 200, { '_query_string' => 'q=test' }.merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :get, '/manifests/search', 400, {}.merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :post, '/manifests/validate', 200, { '_data' => manifest_as_json.to_json }.merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :post, '/manifests/validate', 422, { '_data' => { invalid_json: true }.to_json }.merge(header_params)
      )
    end
    it do
      expect(subject).to validate(:get, '/method_codes', 200, header_params)
    end
  end

  context 'and' do
    it 'tests all documented routes' do
      pending("swagger schema incomplete")
      expect(subject).to validate_all_paths
    end
  end

  def manifest
    @_manifest ||= create(:manifest, user: @current_session.user)
  end

  def params
    @_params ||= { 'id' => manifest.uuid }
  end

  def unknown_manifest_params
    { 'id' => 'foobar' }
  end

  def header_params
    { '_headers' => set_headers }
  end

  def patch_params
    { '_data' => manifest_patch_as_json.to_json }
  end

  def manifest_as_json
    manifest = read_example_json_file_as_json('manifest')
    manifest['generator']['manifest_tracking_number'] = random_tracking_number
    manifest
  end

  def manifest_patch_as_json
    read_example_json_file_as_json('manifest_patch')
  end
end

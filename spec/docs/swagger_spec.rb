require 'rails_helper'
include JsonSchemaSpecHelper

describe 'Swagger docs', type: :apivore, order: :defined do
  before(:all) do
    register_schemas_by_uri
  end

  subject { Apivore::SwaggerChecker.instance_for('/api-documentation/swagger.json') }

  context 'has valid paths' do
    it do
      expect(subject).to validate(:get, '/manifests/{id}', 200, params)
    end
    it do
      expect(subject).to validate(:get, '/manifests/{id}', 404, unknown_manifest_params)
    end
    it do
      expect(subject).to validate(
        # TODO must we require 'manifest' key? that is inconsistent with PATCH and /validate
        :post, '/manifests', 201, { '_data' => { manifest: manifest_as_json }.to_json }.merge(header_params)
      )
    end
    it do
      expect(subject).to validate(
        :post, '/manifests', 422, { '_data' => { manifest: { invalid_json: true } }.to_json }.merge(header_params)
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
        :get, '/manifests/search', 200, { '_query_string' => 'q=test' }
      )
    end
    it do
      expect(subject).to validate(
        :get, '/manifests/search', 400, {}
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
      expect(subject).to validate(:get, '/method_codes', 200)
    end
  end

  context 'and' do
    it 'tests all documented routes' do
      pending("swagger schema incomplete")
      expect(subject).to validate_all_paths
    end
  end

  def manifest
    @_manifest ||= create(:manifest)
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
    read_example_file_as_json('manifest')
  end

  def manifest_patch_as_json
    read_example_file_as_json('manifest_patch')
  end

  def read_example_file_as_json(name)
    JSON.parse(File.read("#{Rails.root.join('app', 'views', 'examples')}/_#{name}.json"))
  end
end

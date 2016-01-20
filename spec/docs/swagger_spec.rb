require 'rails_helper'
include JsonSchemaSpecHelper

describe 'Swagger docs', type: :apivore, order: :defined do
  before(:all) do
    register_schemas_by_uri
  end

  subject { Apivore::SwaggerChecker.instance_for('/api-documentation/swagger.json') }

  context 'has valid paths' do
    it do
      expect(subject).to validate(
        :get, '/manifests/{id}', 200, params
      )
    end
    it do
      expect(subject).to validate(
        :post, '/manifests', 201, { '_data' => { manifest: JSON.parse(manifest_as_json) }.to_json, '_headers' => set_headers }
      )
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

  def manifest_as_json
    File.read("#{Rails.root.join('app', 'views', 'examples')}/_manifest.json")
  end
end

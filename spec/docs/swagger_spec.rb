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
end

require 'rails_helper'

describe 'Swagger docs', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/api-documentation/swagger.json') }

  context 'has valid paths' do
    specify do
      expect(subject).to validate(
        :get, '/manifests/{id}', 200, params
      )
    end
  end

  context 'and' do
    it 'tests all documented routes' do
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

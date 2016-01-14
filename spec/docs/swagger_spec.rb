require 'rails_helper'

describe 'Swagger docs', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/api-documentation/swagger.json') }

  context 'has valid paths' do
    specify do
      expect(subject).to validate(
        :get, '/manifest', 200, {'_query_string' => query_string }
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
    @_params ||= { id: manifest.uuid }
  end

  def query_string
    params.to_query
  end
end

require 'rails_helper'
require "queryparams"

describe 'manifests search', elasticsearch: true do
  context 'ui' do
    it 'supports structured query syntax' do
      manifest = create(:manifest, :indexed)
      get "/manifests?aq[content.generator.name]=company"
      expect(response.body).to include(manifest.tracking_number.to_s)
    end
  end
end

require 'rails_helper'
require "queryparams"

describe 'manifests search', elasticsearch: true do
  context 'ui' do
    it 'supports structured query syntax' do
      manifest = create(:manifest, :indexed)
      get "/manifests?aq[content.generator.name]=company"
      expect(response.body).to include(manifest.tracking_number.to_s)
    end

    it 'paginates' do
      5.times { create(:manifest, :indexed) }
      get "/manifests?aq[content.generator.name]=company&page=2&size=2"
      expect(response.body).to include("Currently viewing 3-4 of 5 results")
    end
  end
end

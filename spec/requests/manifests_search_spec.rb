require 'rails_helper'
require_relative '../../db/chores/populator'
require "queryparams"

describe 'manifests search', elasticsearch: true do
  context 'ui' do
    it 'supports structured query syntax' do
      populate_manifests(2)
      manifest = Manifest.last
      get "/manifests?aq[content.generator.name]=generator"
      expect(response.body).to include(manifest.tracking_number.to_s)
    end
  end

  def populate_manifests(nrecords=10)
    populator = Populator.new(Manifest)
    populator.run(nrecords)
    Manifest.rebuild_index
  end
end

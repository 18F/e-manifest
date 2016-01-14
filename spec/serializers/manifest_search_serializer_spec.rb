require 'rails_helper'

describe ManifestSearchSerializer do
  it "runs hits through ManifestSerializer", elasticsearch: true do
    start_es_server  # TODO ditch once PR #48 merged
    manifest = Manifest.create(content: {})
    Manifest.rebuild_index
    manifest.reload
    
    es_response = Manifest.authorized_search({q: manifest.uuid})
    serialized = ManifestSearchSerializer.new(es_response).to_json(root: false)
    serialized_from_json = JSON.parse(serialized)
    expect(serialized_from_json['total']).to eq 1
    expect(serialized_from_json['hits'][0]['id']).to eq(manifest.uuid)
    stop_es_server # TODO ditch once PR #48 merged
  end
end

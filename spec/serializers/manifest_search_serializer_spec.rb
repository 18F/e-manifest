require 'rails_helper'

describe ManifestSearchSerializer do
  it "runs hits through ManifestSerializer", elasticsearch: true do
    manifest = create(:manifest)
    Manifest.rebuild_index
    manifest.reload
    es_execute_with_retries 3 do
      es_response = Manifest.authorized_search({q: manifest.uuid})[:es_response]
    end
    serialized = ManifestSearchSerializer.new(es_response).to_json

    serialized_from_json = JSON.parse(serialized)
    expect(serialized_from_json['total']).to eq 1
    expect(serialized_from_json['hits'][0]['id']).to eq(manifest.uuid)
  end
end

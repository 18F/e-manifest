require 'rails_helper'

describe ManifestSerializer do
  it "masks id with uuid" do
    manifest = create(:manifest)
    manifest.reload

    serialized = ManifestSerializer.new(manifest).to_json

    expect(JSON.parse(serialized)['id']).to eq manifest.uuid
  end
end

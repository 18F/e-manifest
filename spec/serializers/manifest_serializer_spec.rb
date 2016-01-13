require 'rails_helper'

describe ManifestSerializer do
  it "masks id with uuid" do
    manifest = Manifest.create(content: {})
    manifest.reload
    serialized = ManifestSerializer.new(manifest).to_json(root: false)
    expect(JSON.parse(serialized)['id']).to eq manifest.uuid
  end
end

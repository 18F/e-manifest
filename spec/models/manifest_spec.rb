require 'rails_helper'

describe Manifest do
  it "gets default valid v4 UUID" do
    manifest = Manifest.create(content: {})
    manifest.reload
    expect(manifest.uuid).to match(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/)
  end

  it "#as_public_json masks internal PK id" do
    manifest = Manifest.create(content: {})
    manifest.reload
    expect(manifest.id).to_not eq(manifest.uuid)
    expect(manifest.as_public_json['id']).to eq(manifest.uuid)
  end

  it "#to_public_json" do
    manifest = Manifest.create(content: {})
    manifest.reload
    expect(manifest.to_public_json).to eq manifest.as_public_json.to_json
  end
end

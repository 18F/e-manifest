require 'rails_helper'

describe ManifestValidator do
  it "handles either JSON string or object" do
    json = { foo: 'bar' }
    validator = ManifestValidator.new(json)
    expect(validator.content).to eq( json )
    validator = ManifestValidator.new(json.to_json)
    expect(validator.content).to eq( { 'foo' => 'bar' } )
  end

  it "returns false on invalid JSON" do
    json = { foo: 'bar' }.to_json
    validator = ManifestValidator.new(json)
    expect(validator.run).to eq false
  end

  it "populates errors on invalid JSON" do
    json = { foo: 'bar' }.to_json
    validator = ManifestValidator.new(json)
    validator.run
    expect(validator.errors.size).to eq 2
    expect(validator.errors.map { |e| e[:message] }).to include(
      "The property '#/' contained undefined properties: 'foo' in schema https://e-manifest.18f.gov/schemas/post-manifest.json"
    )
  end
end

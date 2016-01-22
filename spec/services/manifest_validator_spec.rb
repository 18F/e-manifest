require 'rails_helper'
include ExampleJsonHelper

describe ManifestValidator do
  it "handles either JSON string or object" do
    json = { generator: { manifest_tracking_number: '987654321abc' } }
    validator = ManifestValidator.new(json)
    expect(validator.run).to eq true
    validator = ManifestValidator.new(json.to_json)
    expect(validator.run).to eq true
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
    expect(validator.error_messages).to match_array([
      %Q(The property '#/' contains additional properties ["foo"] outside of the schema when none are allowed in schema https://e-manifest.18f.gov/schemas/post-manifest.json),
      %Q(The property '#/' did not contain a required property of 'generator' in schema https://e-manifest.18f.gov/schemas/post-manifest.json)
    ])
  end

  it "recognizes valid JSON" do
    json = read_example_json_file('manifest')
    validator = ManifestValidator.new(json)
    expect(validator.run).to eq true
    expect(validator.errors).to eq []
  end
end

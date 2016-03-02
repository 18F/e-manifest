require 'rails_helper'
include ExampleJsonHelper

describe "validate manifest" do
  it "returns error for invalid JSON" do
    post "/api/v0/manifests/validate", {}, set_headers('RAW_POST_DATA' => 'foo=bar')
    expect(response.status).to eq 400
  end

  it "returns array of errors for well-formed but schematically invalid JSON" do
    post "/api/v0/manifests/validate", { foo: 'bar' }.to_json, set_headers
    expect(response.status).to eq 422
    expect(JSON.parse(response.body)['errors']).to match_array([
      %Q(The property '#/' contains additional properties ["foo"] outside of the schema when none are allowed in schema https://e-manifest.18f.gov/schemas/post-manifest.json),
      %Q(The property '#/' did not contain a required property of 'generator' in schema https://e-manifest.18f.gov/schemas/post-manifest.json)
    ])
  end

  it "accepts documented example manifest" do
    json = read_example_json_file('manifest')
    post "/api/v0/manifests/validate", json, set_headers
    expect(response.status).to eq 200
  end
end

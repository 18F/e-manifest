require 'rails_helper'

describe 'POST manifests' do
  it 'creates a new manifest' do
    expect {
      post '/api/v0/manifests?tracking_number=30221',
      { hello: 'world' }.to_json
    }.to change { Manifest.count }.by(1)

    manifest = Manifest.last

    expect(manifest.content).to eq({ 'hello' => 'world' })
    expect(response.headers['Location']).to eq("/api/v0/manifests/#{manifest.id}")
  end
end

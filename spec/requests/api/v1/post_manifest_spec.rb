require_relative "../../../support/request_spec_helper"

describe 'POST manifests' do
  it 'creates a new manifest' do
    expect {
      send_json(:post, '/api/v1/manifests?tracking_number=30221', { hello: 'world' })
    }.to change { Manifest.count }.by(1)

    manifest = Manifest.last

    expect(manifest.content).to eq({ 'hello' => 'world' })
    expect(last_response.headers['Location']).to eq("/api/v1/manifests/#{manifest.id}")
  end
end

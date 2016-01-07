require_relative "../../../request_spec_helper"

describe 'POST manifest/submit/:manifest_tracking_number' do
  it 'creates a new manifest' do
    expect {
      send_json(:post, '/api/0.1/manifest/submit/30221', { hello: 'world' })
    }.to change { Manifest.count }.by(1)

    manifest = Manifest.last

    expect(manifest.content).to eq({ 'hello' => 'world' })
    expect(last_response.headers['Location']).to eq("/api/0.1/manifest/id/#{manifest.id}")
  end
end

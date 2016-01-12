require 'rails_helper'

describe 'POST manifests' do
  it 'creates a new manifest' do
    expect {
      post '/api/v0/manifests',
        { manifest: { manifest_tracking_number: 'test_number' } }.to_json,
        set_headers
    }.to change { Manifest.count }.by(1)

    manifest = Manifest.last

    expect(manifest.content).to eq({ 'manifest_tracking_number' => 'test_number' })
  end
end

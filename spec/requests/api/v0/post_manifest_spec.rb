require 'rails_helper'

describe 'POST manifests' do
  context 'valid manifest params' do
    it 'creates a new manifest' do
      expect {
        post '/api/v0/manifests',
          {
            manifest: {
              generator: { manifest_tracking_number: 'test_number' }
            }
          }.to_json,
          set_headers
      }.to change { Manifest.count }.by(1)

      manifest = Manifest.last

      expect(manifest.content).to eq({
        'generator' => { 'manifest_tracking_number' => 'test_number' }
      })
    end
  end

  context 'invalid manifest params' do
    it 'returns helpful error messages' do
      expect {
        post '/api/v0/manifests',
          {}.to_json,
          set_headers
      }.to change { Manifest.count }.by(0)

      response_json = JSON.parse(response.body)
      expect(response.status).to eq 422
      expect(response_json).to eq({
        'message' => 'Validation failed',
        'errors' => "Tracking number can't be blank"
      })
    end
  end
end

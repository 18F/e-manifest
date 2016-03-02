require 'rails_helper'

describe 'POST manifests' do
  context 'authorization' do
    it 'requires authentication' do
      manifest_tracking_number = "987654321abc"
      expect {
        post '/api/v0/manifests',
          { generator: { manifest_tracking_number: manifest_tracking_number } }.to_json,
          set_headers
      }.to change { Manifest.count }.by(0)

      expect(response.status).to eq(403)
    end
  end

  context 'valid manifest params' do
    it 'creates a new manifest' do
      mock_authenticated_session
      manifest_tracking_number = "987654321abc"
      expect {
        post '/api/v0/manifests',
          { generator: { manifest_tracking_number: manifest_tracking_number } }.to_json,
          set_headers
      }.to change { Manifest.count }.by(1)

      manifest = Manifest.last

      expect(manifest.content).to eq({
        'generator' => { 'manifest_tracking_number' => manifest_tracking_number }
      })
    end
  end

  context 'returns helpful error messages when' do
    it 'missing generator key' do
      mock_authenticated_session
      expect {
        post '/api/v0/manifests',
          {}.to_json,
          set_headers
      }.to change { Manifest.count }.by(0)

      response_json = JSON.parse(response.body)
      expect(response.status).to eq 422
      expect(response_json).to eq({
        'message' => 'Validation failed',
        'errors' => ["The property '#/' did not contain a required property of 'generator' in schema https://e-manifest.18f.gov/schemas/post-manifest.json"]
      })
    end

    it 'requires min length manifest tracking number' do
      mock_authenticated_session
      expect {
        post '/api/v0/manifests',
          { generator: { manifest_tracking_number: "abc123" } }.to_json,
          set_headers
      }.to change { Manifest.count }.by(0)

      response_json = JSON.parse(response.body)
      expect(response.status).to eq 422
      expect(response_json).to eq({
        'message' => 'Validation failed',
        'errors' => [
          "The property '#/generator/manifest_tracking_number' was not of a minimum string length of 12 in schema https://e-manifest.18f.gov/schemas/post-manifest.json",
          "The property '#/generator/manifest_tracking_number' value \"abc123\" did not match the regex '^[0-9]{9}[A-Za-z]{3}$' in schema https://e-manifest.18f.gov/schemas/post-manifest.json"
        ]
      })
    end

    it 'requires manifest tracking number to be a String' do
      mock_authenticated_session
      expect {
        post '/api/v0/manifests',
          { generator: { manifest_tracking_number: 123 } }.to_json,
          set_headers
      }.to change { Manifest.count }.by(0)

      response_json = JSON.parse(response.body)
      expect(response.status).to eq 422
      expect(response_json).to eq({
        'message' => 'Validation failed',
        'errors' => [
          "The property '#/generator/manifest_tracking_number' of type Fixnum did not match the following type: string in schema https://e-manifest.18f.gov/schemas/post-manifest.json",
        ]
      })
    end

    it 'requires manifest tracking number be unique' do
      mock_authenticated_session
      manifest = create(:manifest)
      expect {
        post '/api/v0/manifests',
        manifest.content.to_json,
        set_headers
      }.to change { Manifest.count }.by(0)

      response_json = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq 422
      expect(response_json).to eq({
        message: 'Validation failed',
        errors: 'Tracking number must be unique'
      })
    end
  end
end

require 'sinatra'
require 'json'

# API Routes

# Submit Manifest
post '/api/manifest/submit/:manifest_tracking_number' do |mtn|
  "Manifest #{mtn} submitted!\n"\
  "Request body: #{request.body.read}\n"
end

# Search for Manifests
get '/api/manifest/search' do
  content_type :json
  {
    params: {
      manifest_tracking_number: params['manifest_tracking_number'],
      generator_name: params['generator_name'],
      generator_id: params['generator_id'],
      waste_codes: params['waste_codes'],
      city: params['city'],
      state: params['state']
    },
    results: [
      manifest_tracking_number: 12345,
      generator_name: 'ACME, Inc',
      generator_id: 12345,
      date: Time.new
    ]
  }.to_json
end

# Update Manifest
patch '/api/manifest/update/:manifest_tracking_number' do
  content_type :json
  {
    params: {
      fields_to_update: params['fields_to_update']
    },
    status: 'success',
    errors: [],
    warnings: ['Waste code 1234 not recognized']
  }.to_json
end

require_relative 'app_manifest'

class App < Sinatra::Base
  configure do
    set :logging, true
    if url = ENV['DATABASE_URL']
      ConnectAR.new(url)
    end
  end

  configure :development do
    set :show_exceptions, true
  end

  configure :test do
    ActiveRecord::Base.logger = Logger.new(
      File.new(File.dirname(__FILE__) + '/../log/test.log', 'w')
    )
  end

  ### API Routes ###

  # Submit Manifest
  post '/api/manifest/submit/:manifest_tracking_number' do |mtn|
    @manifest_row = Manifest.new(content: JSON.parse(request.body.read))
    @manifest_row.save

    request.body.rewind
    "Manifest #{mtn} submitted!\n"\
    "Request body: #{request.body.read}\n"
    response.headers['Location'] = "/api/manifest/id/#{@manifest_row.id}"
    status 201
  end

  # Search for Manifests
  get '/api/manifest/search' do
    content_type :json
    Manifest.all.to_json
  end

  # Search for Manifests
  get '/api/manifest/id/:manifest_id' do
    begin
      response = Manifest.find(params["manifest_id"])
      response.to_json
    rescue ActiveRecord::RecordNotFound => e
      status 404
    end
  end

  # Reset Database
  get '/reset' do
    #Manifest.delete_all
    "Database has been reset!"
  end

  post '/api/user/authenticate' do
    body = request.body.read
    authentication = JSON.parse(body)
    response = CDX::Authenticator.new(authentication).perform
    content_type :json
    response.to_json
  end

  post '/api/manifest/sign' do
    sign_request = JSON.parse(request.body.read)
    manifest_id = sign_request["id"]
    manifest = Manifest.find(manifest_id)
    manifest_content = manifest[:content].to_json
    sign_request[:manifest_content] = manifest_content
    puts manifest_content
    puts sign_request
    response = CDX::Manifest.new(sign_request).sign

    if (response.key?(:document_id))
      manifest[:document_id] = response[:document_id]
      manifest[:activity_id] = sign_request["activity_id"]
      manifest.save
    end

    content_type :json
    response.to_json
  end
end


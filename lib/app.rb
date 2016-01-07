require_relative 'app_manifest'

class App < Sinatra::Base
  configure do
    set :logging, true
    if url = ENV['DATABASE_URL']
      ConnectAR.new(url)
    end
    use Rack::Session::Pool, :cookie_only => false, :defer => true
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
  post "/api/:version/manifest/submit/:manifest_tracking_number" do |version, mtn|
    @manifest_row = Manifest.new(content: JSON.parse(request.body.read))
    @manifest_row.save

    request.body.rewind
    "Manifest #{mtn} submitted!\n"\
    "Request body: #{request.body.read}\n"
    response.headers['Location'] = "/api/#{version}/manifest/id/#{@manifest_row.id}"
    status 201
  end

  # Search for Manifests
  get '/api/:version/manifest/search' do
    content_type :json
    if !params[:q] && !params[:aq]
      status 400
    else
      Manifest.authorized_search(params).response[:hits].to_json
    end
  end

  # Get a Manifest by e-Manifest id
  get '/api/:version/manifest/id/:manifest_id' do
    begin
      response = Manifest.find(params["manifest_id"])
      response.to_json
    rescue ActiveRecord::RecordNotFound => e
      status 404
    end
  end

  # Get a Manifest by manifest tracking number
  get '/api/:version/manifest/:manifest_tracking_number' do
    begin
      manifest_tracking_number = params["manifest_tracking_number"]
      response = Manifest.where("content -> 'generator' ->> 'manifest_tracking_number' = ?", manifest_tracking_number)
      if response.empty?
        status 404
        return
      end

      response.first.to_json
    end
  end

  # Update a Manifest by e-Manifest id
  patch '/api/:version/manifest/id/:manifest_id' do
    begin
      manifest = Manifest.find(params["manifest_id"])
      patch = JSON.parse(request.body.read)
      patch_json = patch.to_json

      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json);
      manifest.update_column(:content, new_json)

      manifest.to_json
    rescue ActiveRecord::RecordNotFound => e
      status 404
    end
  end

  # Update a Manifest by manifest tracking number
  patch '/api/:version/manifest/:manifest_tracking_number' do
    begin
      manifest_tracking_number = params["manifest_tracking_number"]
      manifest_collection = Manifest.where("content -> 'generator' ->> 'manifest_tracking_number' = ?", manifest_tracking_number)
      if manifest_collection.empty?
        status 404
        return
      end
      manifest = manifest_collection.first
      patch = JSON.parse(request.body.read)
      patch_json = patch.to_json
      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json);
      manifest.update_column(:content, new_json)
      manifest.to_json
    end
  end

  # Reset Database
  get '/reset' do
    #Manifest.delete_all
    "Database has been reset!"
  end

  post '/api/:version/user/authenticate' do
    body = request.body.read
    authentication = JSON.parse(body)
    response = CDX::Authenticator.new(authentication).perform
    content_type :json
    session[:system_session_token] = response[:token]
    response[:token] = session.id
    response.to_json
  end

  post '/api/:version/manifest/sign' do
    sign_request = JSON.parse(request.body.read)
    manifest_id = sign_request["id"]
    manifest = Manifest.find(manifest_id)
    manifest_content = manifest[:content].to_json
    sign_request[:manifest_content] = manifest_content
    emanifest_session_id = sign_request["token"]
    session.id = emanifest_session_id
    session[:load_by_id_hack] = 'official docs make finding a session by session id difficult'
    session.delete(:load_by_id_hack)
    system_session_token = session[:system_session_token]
    sign_request["token"] = system_session_token

    response = CDX::Manifest.new(sign_request).sign

    if (response.key?(:document_id))
      manifest[:document_id] = response[:document_id]
      manifest[:activity_id] = sign_request["activity_id"]
      manifest.save
    end

    content_type :json
    response.to_json
  end

  post '/api/:version/manifest/signByTrackingNumber' do
    sign_request = JSON.parse(request.body.read)
    manifest_tracking_number = sign_request["manifest_tracking_number"]
    manifest_collection = Manifest.where("content -> 'generator' ->> 'manifest_tracking_number' = ?", manifest_tracking_number)
    if manifest_collection.empty?
      status 404
      return
    end
    manifest = manifest_collection.first
    manifest_content = manifest[:content].to_json
    sign_request[:manifest_content] = manifest_content
    emanifest_session_id = sign_request["token"]
    session.id = emanifest_session_id
    session[:load_by_id_hack] = 'official docs make finding a session by session id difficult'
    session.delete(:load_by_id_hack)
    system_session_token = session[:system_session_token]
    sign_request["token"] = system_session_token

    response = CDX::Manifest.new(sign_request).sign

    if (response.key?(:document_id))
      manifest[:document_id] = response[:document_id]
      manifest[:activity_id] = sign_request["activity_id"]
      manifest.save
    end

    content_type :json
    response.to_json
  end

  get '/api/:version/method_code' do
    content_type :json
    IO.read(File.dirname(__FILE__) + "/../public/api-data/method-codes.json")
  end
end


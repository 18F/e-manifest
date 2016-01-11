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

  post "/api/:version/manifests" do |version|
    @manifest_row = Manifest.new(content: JSON.parse(request.body.read))
    @manifest_row.save

    request.body.rewind
    "Manifest #{params[:tracking_number]} submitted!\n"\
    "Request body: #{request.body.read}\n"
    response.headers['Location'] = "/api/#{version}/manifests/#{@manifest_row.id}"
    status 201
  end

  get '/api/:version/manifests/search' do
    content_type :json
    if !params[:q] && !params[:aq]
      status 400
    else
      Manifest.authorized_search(params).response[:hits].to_json
    end
  end

  get '/api/:version/manifest' do
    begin
      if params[:id]
        manifest = Manifest.find(params[:id])
      elsif params[:tracking_number]
        manifest = Manifest.find_by!("content -> 'generator' ->> 'manifest_tracking_number' = ?", params[:tracking_number])
      end
    rescue ActiveRecord::RecordNotFound => _error
      status 404
      return
    end

    manifest.to_json
  end

  patch '/api/:version/manifests' do
    begin
      if params[:id]
        manifest = Manifest.find(params[:id])
      elsif params[:tracking_number]
        manifest = Manifest.find_by!("content -> 'generator' ->> 'manifest_tracking_number' = ?", params[:tracking_number])
      end

      patch = JSON.parse(request.body.read)
      patch_json = patch.to_json

      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json);
      manifest.update_column(:content, new_json)

      manifest.to_json
    rescue ActiveRecord::RecordNotFound => _error
      status 404
    end
  end

  post '/api/:version/tokens' do
    body = request.body.read
    authentication = JSON.parse(body)
    response = CDX::Authenticator.new(authentication).perform
    content_type :json
    session[:system_session_token] = response[:token]
    response[:token] = session.id
    response.to_json
  end

  post '/api/:version/manifests/:manifest_id/signature' do
    manifest = find_manifest_by_id_or_tracking_number(params[:manifest_id])

    if manifest.nil?
      status 404
      return
    end

    sign_request = JSON.parse(request.body.read)
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

  get '/api/:version/method_codes' do
    content_type :json
    IO.read(File.dirname(__FILE__) + "/../public/api-data/method-codes.json")
  end

  private

  def find_manifest_by_id_or_tracking_number(id)
    Manifest.where(id: id).first ||
      Manifest.where("content -> 'generator' ->> 'manifest_tracking_number' = ?", id).first
  end
end


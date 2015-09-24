require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require_relative 'cdx_client'

### Database Configuration ###

configure :development do
 set :database, 'postgres://localhost/e-manifest' unless ENV['DATABASE_URL'].present?
 set :show_exceptions, true
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'])

  ActiveRecord::Base.establish_connection(
   :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
   :host     => db.host,
   :username => db.user,
   :password => db.password,
   :database => db.path[1..-1],
   :encoding => 'utf8'
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
end

# Search for Manifests
get '/api/manifest/search' do
  content_type :json
  Manifest.all.to_json
end

# Reset Database
get '/reset' do
  Manifest.delete_all
  "Database has been reset!"
end

post '/api/user/authenticate' do
  authentication = JSON.parse(request.body.read)
  authenticate_user authentication
end

### Data Models ###

class Manifest < ActiveRecord::Base
end

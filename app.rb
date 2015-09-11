require 'sinatra'
require 'json'
require 'sinatra/activerecord'

configure :development do
 set :database, 'postgres://localhost/e-manifest'
 set :show_exceptions, true
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/e-manifest')

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
  @manifest_row = Manifest.new(content: request.body.read)
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
end

### Data Models ###

class Manifest < ActiveRecord::Base
end

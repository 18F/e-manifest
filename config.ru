require 'sidekiq/web'
require ::File.expand_path('../config/environment', __FILE__)

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
end

run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)
run Rails.application

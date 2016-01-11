# config.ru

require 'rack/contrib/try_static'
require File.dirname(__FILE__) + "/lib/app"
require 'sidekiq/web'

use Rack::TryStatic,
  :root => 'public',
  :urls => %w[/],
  :try => ['.html', 'index.html', '/index.html']

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
end

run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)

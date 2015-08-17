# config.ru

require 'rack/contrib/try_static'
require './app'

use Rack::TryStatic, 
  :root => 'public',
  :urls => %w[/],
  :try => ['.html', 'index.html', '/index.html']

run Sinatra::Application

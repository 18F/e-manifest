# config.ru

require 'rack/contrib/try_static'
require File.dirname(__FILE__) + "/lib/app"

use Rack::TryStatic,
  :root => 'public',
  :urls => %w[/],
  :try => ['.html', 'index.html', '/index.html']

run App

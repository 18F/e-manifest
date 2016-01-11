require 'rack/test'
require 'rspec'
require "savon/mock/spec_helper"

require File.dirname(__FILE__) + "/../../lib/app.rb"

ENV['RACK_ENV'] = 'test'

module RequestSpecHelper
  include Rack::Test::Methods
  def app
    App
  end

  def send_json(method, url, data)
    send(method, url, data.to_json, { "Content-Type" => "application/json" })
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper
end

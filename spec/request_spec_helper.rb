require 'rack/test'
require 'rspec'
require "savon/mock/spec_helper"

require File.dirname(__FILE__) + "/../lib/app.rb"

ENV['RACK_ENV'] = 'test'

module RequestMixin
  include Rack::Test::Methods
  def app
    App
  end

  def send_json(method, url, data)
    send(method, url, data.to_json, { "CONTENT_TYPE" => "application/json" })
  end
end

RSpec.configure do |config|
  config.include RequestMixin
end



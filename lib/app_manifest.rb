require 'json'
require 'forwardable'
require 'logger'

require 'rubygems'
require 'bundler'

Bundler.require

lib_dir = File.dirname(__FILE__)

require "#{lib_dir}/connect_ar"
require "#{lib_dir}/cdx"
require "#{lib_dir}/workers/indexer_worker"
require "#{lib_dir}/models/manifest"

####################################################################
## Sidekiq config

Sidekiq.configure_server do |config|
end

####################################################################
## Elasticsearch config
require "elasticsearch/model"

# defaults
es_client_args = {
  transport_options: {
    request: {
      timeout: 1800,
      open_timeout: 1800,
    }
  },
  retry_on_failure: 5,
}

# we use "production" env for all things at cloud.gov
if ENV["RACK_ENV"] == "production"
  vcap = ENV["VCAP_SERVICES"]
  vcap_config = JSON.parse(vcap)
  vcap_config.keys.each do |vcap_key|
    if vcap_key.match(/elasticsearch/)
      es_config = vcap_config[vcap_key]
      es_client_args[:url] = es_config[0]["credentials"]["uri"]
    end
  end
elsif ENV["RACK_ENV"] == "test"
  es_client_args[:url] = "http://localhost:#{(ENV['TEST_CLUSTER_PORT'] || 9250)}"
else
  es_client_args[:url] = ENV["ES_URL"] || "http://localhost:9200"
end

# optional verbose logging based on env var, regardless of environment.
if ENV["ES_DEBUG"].to_i > 0
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  tracer = Logger.new(STDERR)
  tracer.formatter = ->(_s, _d, _p, m) { "#{m.gsub(/^.*$/) { |n| '   ' + n }}\n" }
  es_client_args[:log] = true
  es_client_args[:logger] = logger
  es_client_args[:tracer] = tracer
  logger.debug "[#{Time.now.utc.iso8601}] Elasticsearch logging set to DEBUG mode"
end

Elasticsearch::Model.client = Elasticsearch::Client.new(es_client_args)

if ENV["ES_DEBUG"]
  es_client_args[:logger].debug "[#{Time.now.utc.iso8601}] Using Elasticsearch server #{es_client_args[:url]}"
end

require 'stringio'
ENV['RACK_ENV'] = 'test'
require_relative '../lib/app_manifest'
require 'database_cleaner'

require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

require 'database_cleaner'

require File.dirname(__FILE__) + "/support/api_schema_matcher.rb"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  if ENV["RSPEC_PROFILE"]
    config.profile_examples = 10
  end

  config.order = :random
  Kernel.srand config.seed
end

require 'stringio'
ENV['RACK_ENV'] = 'test'
require_relative '../lib/app_manifest'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

require 'json_matchers/rspec'
JsonMatchers.schema_root = 'lib/schemas'

require 'database_cleaner'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

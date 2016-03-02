if ENV.fetch("COVERAGE", false)
    require "simplecov"
      SimpleCov.start "rails"
end

require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'spec/support/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<CDX_USERNAME>') { ENV['CDX_USERNAME'] }
  config.filter_sensitive_data('<CDX_PASSWORD>') { ENV['CDX_PASSWORD'] }
end

# http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path =
    "tmp/rspec_examples.txt"
  config.order = :random
end

WebMock.disable_net_connect!(allow_localhost: true, allow: ['json-schema.org'])

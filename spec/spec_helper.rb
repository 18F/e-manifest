require 'stringio'
ENV['RACK_ENV'] = 'test'
require_relative '../lib/app_manifest'
require 'database_cleaner'
require 'elasticsearch/extensions/test/cluster'

def create_es_index(klass)
  errors = []
  completed = 0
  puts "Creating Index for class #{klass}"
  klass.__elasticsearch__.create_index! force: true, index: klass.index_name
  klass.__elasticsearch__.refresh_index!
  klass.__elasticsearch__.import  :return => 'errors', :batch_size => 200    do |resp|
    # show errors immediately (rather than buffering them)
    errors += resp['items'].select { |k, v| k.values.first['error'] }
    completed += resp['items'].size
    puts "Finished #{completed} items"
    STDERR.flush
    STDOUT.flush
    if errors.size > 0
      STDOUT.puts "ERRORS in #{$$}:"
      STDOUT.puts pp(errors)
    end
  end
  puts "Completed #{completed} records of class #{klass}"
end

def start_es_server
  # circleci has locally installed version of elasticsearch so alter PATH to find
  ENV["PATH"] = "./elasticsearch/bin:#{ENV["PATH"]}"

  es_test_cluster_opts = {
    nodes: 1,
    path_logs: "tmp/es-logs"
  }

  unless Elasticsearch::Extensions::Test::Cluster.running?
    Elasticsearch::Extensions::Test::Cluster.start(es_test_cluster_opts)
  end

  # create index(s) to test against.
  create_es_index(Manifest)
end

def stop_es_server
  if Elasticsearch::Extensions::Test::Cluster.running?
    Elasticsearch::Extensions::Test::Cluster.stop
  end
end
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

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    start_es_server unless ENV['ES_SKIP']
  end

  config.after(:suite) do
    stop_es_server unless ENV['ES_SKIP']
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

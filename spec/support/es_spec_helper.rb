require 'elasticsearch/extensions/test/cluster'

module EsSpecHelper
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

end

RSpec.configure do |config|
  config.include EsSpecHelper
  config.before :each, elasticsearch: true do
    start_es_server unless Elasticsearch::Extensions::Test::Cluster.running?
  end
  config.after :suite do
    Elasticsearch::Extensions::Test::Cluster.stop if Elasticsearch::Extensions::Test::Cluster.running?
  end
end

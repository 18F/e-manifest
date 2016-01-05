# Indexer class for <http://sidekiq.org>
#
# Run me with:
#
#     $ bundle exec sidekiq --queue elasticsearch --verbose
#
class IndexerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch', retry: false, backtrace: true

  logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
  tracer = ENV['ES_DEBUG'] ? Logger.new(STDERR) : nil
  if tracer
    tracer.formatter = lambda { |s, d, p, m| "#{m.gsub(/^.*$/) { |n| '   ' + n }.ansi(:faint)}\n" }
  end
  es_url = ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
  Client = Elasticsearch::Client.new host: es_url, logger: logger, tracer: tracer

  def perform(operation, klass, record_id, options={})
    logger.debug [operation, "#{klass}##{record_id} #{options.inspect}"]

    case operation.to_s
      when /index|update/
        record = klass.constantize.find(record_id)
        record.__elasticsearch__.client = Client
        record.__elasticsearch__.__send__ "#{operation}_document"
      when /delete/
        Client.delete index: klass.constantize.index_name, type: klass.constantize.document_type, id: record_id
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end

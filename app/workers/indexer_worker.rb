# Indexer class for <http://sidekiq.org>
#
# Run me with:
#
#     $ bundle exec sidekiq --queue elasticsearch --verbose
#
class IndexerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch', retry: false, backtrace: true

  def perform(operation, klass, record_id, options={})
    klass.constantize.__elasticsearch__.client.logger.debug [operation, "#{klass}##{record_id} #{options.inspect}"]

    case operation.to_s
      when /index|update/
        record = klass.constantize.find(record_id)
        record.__elasticsearch__.__send__ "#{operation}_document"
      when /delete/
        klass.constantize.__elasticsearch__.delete index: klass.constantize.index_name, type: klass.constantize.document_type, id: record_id
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end

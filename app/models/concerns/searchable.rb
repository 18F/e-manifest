module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    ActiveRecord::Base.raise_in_transactional_callbacks = true

    after_commit on: [:create] { reindex_async(:index) }
    after_commit on: [:update] { reindex_async(:update) }
    after_commit on: [:destroy] { reindex_async(:delete) }

    def reindex
      __elasticsearch__.index_document
    end

    def reindex_async(operation)
      unless Rails.env.test?
        IndexerWorker.perform_async(operation,  self.class.to_s, id)
      end
    end

    def remove_from_index
      __elasticsearch__.destroy_document
    end

    def self.rebuild_index
      __elasticsearch__.create_index! force: true
      __elasticsearch__.import
      __elasticsearch__.refresh_index!
    end
  end
end

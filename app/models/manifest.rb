class Manifest < ActiveRecord::Base
  include Elasticsearch::Model

  ActiveRecord::Base.raise_in_transactional_callbacks = true

  after_commit on: [:create] do
    unless Rails.env.test?
      reindex_async
    end
  end

  after_commit on: [:update] do
    unless Rails.env.test?
      reindex_async
    end
  end

  after_commit on: [:destroy] do
    unless test?
      IndexerWorker.perform_async(:delete,  self.class.to_s, self.id)
    end
  end

  def reindex
    __elasticsearch__.index_document
  end

  def reindex_async
    IndexerWorker.perform_async(:index,  self.class.to_s, self.id)
  end

  def remove_from_index
    __elasticsearch__.destroy_document
  end

  def self.rebuild_index
    __elasticsearch__.create_index! force: true
    __elasticsearch__.import
    __elasticsearch__.refresh_index!
  end

  def self.authorized_search(params, current_user=nil)
    dsl = QueryDSL.new(params: params, current_user: current_user)
    search(dsl)
  end
end

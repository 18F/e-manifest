class Manifest < ActiveRecord::Base
  include Elasticsearch::Model

  ActiveRecord::Base.raise_in_transactional_callbacks = true

  after_commit on: [:create] do
    unless test?
      delay.reindex
    end
  end

  after_commit on: [:update] do
    unless test?
      delay.reindex
    end
  end

  after_commit on: [:destroy] do
    unless test?
      delay.remove_from_index
    end
  end

  self.primary_key = "id"

  def reindex
    __elasticsearch__.index_document
  end

  def remove_from_index
    __elasticsearch__.destroy_document
  end

  def self.rebuild_index
    __elasticsearch__.create_index! force: true
    __elasticsearch__.refresh_index!
  end

  def test?
    Sinatra::Application.environment == "test"
  end
end

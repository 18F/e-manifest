require 'date'

require_relative '../search/query_dsl'

class Manifest < ActiveRecord::Base
  validates :tracking_number, presence: true

  def tracking_number
    if content && content["generator"]
      content["generator"]["manifest_tracking_number"] || ''
    end
  end

  def generator_name
    if content && content["generator"]
      content["generator"]["name"] || ''
    end
  end

  def disposal_facility
    if content["generator"] && content["generator"]["designated_facility"]
      content["generator"]["designated_facility"]["name"] || ""
    end
  end

  def created_on
    created_at.strftime('%m/%d/%Y')
  end

  def disposal_facility
    if content["generator"] && content["generator"]["designated_facility"]
      content["generator"]["designated_facility"]["name"] || ""
    end
  end

  def generator_emergency_response_phone
    if content["generator"]
      content["generator"]["emergency_response_phone"] || ""
    end
  end

  def generator_phone_number
    if content["generator"]
      content["generator"]["phone_number"] || ""
    end
  end

  def generator_mailing_address
    if content["generator"]
      content["generator"]["mailing_address"] || {}
    end
  end

  def transporters
    if content["transporters"]
      content["transporters"] || []
    end
  end

  def designated_facility_name
    if content["designated_facility"]
      content["designated_facility"]["name"] || ""
    end
  end

  def designated_facility_signed_date
    if content["designated_facility"]
      y = content["designated_facility"]["certification"]["year"].to_i
      m = content["designated_facility"]["certification"]["month"].to_i
      d = content["designated_facility"]["certification"]["day"].to_i
      Date.new(y, m, d)
    end
  end

  def manifest_items
    if content["manifest_items"]
      content["manifest_items"] || []
    end
  end

  def waste_handling_instructions
    if content["waste_handling_instructions"]
      content["waste_handling_instructions"] || ""
    end
  end

  def waste_report_codes
    if content["report_management_method_codes"]
      content["report_management_method_codes"] || []
    end
  end

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
    unless Rails.env.test?
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

  def self.authorized_search(params, user=nil)
    dsl = Search::QueryDSL.new(params: params, user: user)
    search(dsl)
  end
end

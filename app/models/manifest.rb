require 'date'

require_relative '../search/query_dsl'

class Manifest < ActiveRecord::Base
  validates :tracking_number, presence: true

  before_validation :set_tracking_number, on: :create

  def set_tracking_number
    self.tracking_number = content_field('generator.manifest_tracking_number')
  end

  def content_field(json_xpath)
    fields = json_xpath.split('.')
    if content && fields.inject(content) { |h,k| h[k] if h }
      fields.inject(content) { |h,k| h[k] if h }
    end
  end

  def generator_name
    content_field('generator.name') || ''
  end

  def disposal_facility
    content_field('generator.disposal_facility.name')
  end

  def created_on
    created_at.strftime('%m/%d/%Y')
  end

  def generator_emergency_response_phone
    content_field('generator.emergency_response_phone')
  end

  def generator_phone_number
    content_field('generator.phone_number')
  end

  def generator_mailing_address
    content_field('generator.mailing_address')
  end

  def transporters
    content_field('generator.transporters')
  end

  def designated_facility_name
    content_field('designated_facility.name')
  end

  def designated_facility_signed_date
    if content_field('designated_facility')
      certification = content_field('designated_facility.certification')
      y = certification['year'].to_i
      m = certification['month'].to_i
      d = certification['day'].to_i
      Date.new(y, m, d)
    end
  end

  def manifest_items
    content_field('manifest_items')
  end

  def waste_handling_instructions
    content_field('waste_handling_instructions')
  end

  def waste_report_codes
    content_field('report_management_method_codes')
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

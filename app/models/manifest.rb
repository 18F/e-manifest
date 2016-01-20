require 'date'

class Manifest < ActiveRecord::Base
  validates :tracking_number, presence: true

  def content_field(json_xpath)
    fields = json_xpath.split('.')
    if content && fields.inject(content) { |h,k| h[k] if h }
      fields.inject(content) { |h,k| h[k] if h }
    end
  end

  def tracking_number
    content_field('generator.manifest_tracking_number')
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
    content_field('transporters')
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

  def self.find_by_uuid_or_tracking_number(id)
    find_by(uuid: id) || find_by_tracking_number(id)
  end

  def self.find_by_tracking_number(tracking_number)
    find_by("content -> 'generator' ->> 'manifest_tracking_number' = ?", tracking_number.to_s)
  end

  def self.find_by_uuid_or_tracking_number!(id)
    find_by_uuid_or_tracking_number(id) or raise ActiveRecord::RecordNotFound.new "Could not find #{id} by uuid or tracking_number"
  end

  include Elasticsearch::Model

  ActiveRecord::Base.raise_in_transactional_callbacks = true

  after_commit on: [:create] do
    unless Rails.env.test?
      reindex_async(:index)
    end
  end

  after_commit on: [:update] do
    unless Rails.env.test?
      reindex_async(:update)
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

  def reindex_async(operation)
    IndexerWorker.perform_async(operation,  self.class.to_s, self.id)
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

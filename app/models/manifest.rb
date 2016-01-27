require 'date'

class Manifest < ActiveRecord::Base
  include Searchable

  validate :tracking_number, :validate_tracking_number_unique
  validates :user_id, presence: true
  belongs_to :user, class_name: 'User'

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
    content_field('generator.mailing_address') || {}
  end

  def transporters
    content_field('transporters') || []
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
    content_field('manifest_items') || []
  end

  def waste_handling_instructions
    content_field('waste_handling_instructions')
  end

  def waste_report_codes
    content_field('report_management_method_codes') || []
  end

  def handler_defined
    content_field('handler_defined_data') || []
  end

  def self.find_by_uuid_or_tracking_number(id)
    find_by(uuid: id) || find_by_tracking_number(id)
  end

  def self.find_by_tracking_number(tracking_number)
    find_by("content -> 'generator' ->> 'manifest_tracking_number' = ?", tracking_number.to_s)
  end

  def self.find_by_uuid_or_tracking_number!(id)
    find_by_uuid_or_tracking_number(id) or raise ManifestNotFound.new "Could not find #{id} by uuid or tracking_number"
  end

  def self.authorized_search(params, user=nil)
    dsl = Search::QueryDSL.new(params: params, user: user)
    resp = search(dsl)
    { es_response: resp, dsl: dsl }
  end

  def is_public?
    created_at < 90.days.ago
  end

  private

  def validate_tracking_number_unique
    if tracking_number.blank?
      errors.add(:tracking_number, "must be present")
    elsif tracking_number !~ /^[0-9]{9}[A-Za-z]{3}$/
      errors.add(:tracking_number, "must be 12 characters, starting with 9 numbers and ending with 3 letters")
    elsif tracking_number_already_exists?
      errors.add(:tracking_number, "must be unique")
    elsif exists_with_different_tracking_number?
      errors.add(:tracking_number, "must be unique")
    end
  end

  def tracking_number_already_exists?
    !id && Manifest.find_by_tracking_number(tracking_number)
  end

  def exists_with_different_tracking_number?
    existing = Manifest.find_by_tracking_number(tracking_number)
    id && existing && existing.id != id
  end
end

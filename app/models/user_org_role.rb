class UserOrgRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  belongs_to :role

  validates :user_id, :role_id, :organization_id, :cdx_user_role_id, :cdx_status, presence: true

  def profile_field(json_xpath)
    fields = json_xpath.split('.')
    if profile && fields.inject(profile) { |h,k| h[k] if h }
      fields.inject(profile) { |h,k| h[k] if h }
    end
  end

  def subject
    profile_field('subject')
  end

  def state
    subject
  end
end

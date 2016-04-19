class UserOrgRole < ActiveRecord::Base
  include JsonProfile

  belongs_to :user
  belongs_to :organization
  belongs_to :role

  validates :user_id, :role_id, :organization_id, :cdx_user_role_id, :cdx_status, presence: true

  def subject
    profile_field('subject')
  end

  def state
    subject
  end
end

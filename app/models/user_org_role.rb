class UserOrgRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  belongs_to :role

  validates :user_id, :role_id, :organization_id, :cdx_user_role_id, :cdx_status, presence: true
end

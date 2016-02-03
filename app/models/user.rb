class User < ActiveRecord::Base
  validates :cdx_user_id, presence: true, uniqueness: true

  has_many :manifests
  has_many :user_org_roles, class_name: 'UserOrgRole'
  has_many :roles, through: :user_org_roles
  has_many :organizations, through: :user_org_roles

  def self.find_or_create(cdx_user_id)
    find_by(cdx_user_id: cdx_user_id) || create(cdx_user_id: cdx_user_id)
  end
end

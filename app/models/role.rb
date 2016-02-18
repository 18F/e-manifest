class Role < ActiveRecord::Base
  has_many :user_org_roles
  has_many :users, through: :user_org_roles
  has_many :organizations, through: :user_org_roles

  validates :cdx_role_name, :cdx_role_code, presence: true

  def self.from_cdx(cdx_role)
    find_from_cdx(cdx_role) || create_from_cdx(cdx_role)
  end

  def tsdf_certifier?
    cdx_role_name == "TSDF Certifier" || cdx_role_code == "112110"
  end

  private

  def self.find_from_cdx(cdx_role)
    find_by(cdx_role_name: cdx_role[:type][:description], cdx_role_code: cdx_role[:type][:code])
  end

  def self.create_from_cdx(cdx_role)
    create(cdx_role_name: cdx_role[:type][:description], cdx_role_code: cdx_role[:type][:code])
  end
end

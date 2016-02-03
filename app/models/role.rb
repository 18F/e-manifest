class Role < ActiveRecord::Base
  has_many :user_org_roles

  validates :cdx_role_name, :cdx_role_code, presence: true

  def from_cdx(cdx_role)
    find_from_cdx(cdx_role) || create_from_cdx(cdx_role)
  end

  private

  def find_from_cdx(cdx_role)
    find_by(cdx_role_name: cdx_role[:type][:description], cdx_role_code: cdx_role[:type][:code])
  end

  def create_from_cdx(cdx_role)
    create(cdx_role_name: cdx_role[:type][:description], cdx_role_code: cdx_role[:type][:code])
  end
end

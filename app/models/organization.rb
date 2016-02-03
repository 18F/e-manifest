class Organization < ActiveRecord::Base
  has_many :user_org_roles

  validates :cdx_org_name, :cdx_org_id, presence: true

  def from_cdx(cdx_org)
    find_from_cdx(cdx_org) || create_from_cdx(cdx_org)
  end

  private

  def find_from_cdx(cdx_org)
    find_by(cdx_org_name: cdx_org[:organization_name], cdx_org_id: cdx_org[:organization_id])
  end

  def create_from_cdx(cdx_org)
    create(cdx_org_name: cdx_org[:organization_name], cdx_org_id: cdx_org[:organization_id])
  end
end

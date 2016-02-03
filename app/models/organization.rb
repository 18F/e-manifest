class Organization < ActiveRecord::Base
  has_many :user_org_roles

  validates :cdx_org_name, :cdx_org_id, presence: true

  def self.from_cdx(cdx_org)
    find_from_cdx(cdx_org) || create_from_cdx(cdx_org)
  end

  private

  def self.find_from_cdx(cdx_org)
    find_by(cdx_org_name: cdx_org[:organization_name], cdx_org_id: cdx_org[:organization_id])
  end

  def self.create_from_cdx(cdx_org)
    create(cdx_org_name: cdx_org[:organization_name], cdx_org_id: cdx_org[:organization_id])
  end
end

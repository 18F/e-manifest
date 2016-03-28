class Organization < ActiveRecord::Base
  has_many :user_org_roles
  has_many :users, through: :user_org_roles
  has_many :roles, through: :user_org_roles

  validates :cdx_org_name, :cdx_org_id, presence: true

  def self.from_cdx(cdx_org)
    find_from_cdx(cdx_org) || create_from_cdx(cdx_org)
  end

  def state
    profile["state"]["code"]
  end

  def city
    profile["city"]
  end

  def email
    profile["email"]
  end

  def zip
    profile["zip"]
  end

  private

  def self.find_from_cdx(cdx_org)
    find_by(cdx_org_name: cdx_org[:organizationName], cdx_org_id: cdx_org[:organizationId])
  end

  def self.create_from_cdx(cdx_org)
    create(cdx_org_name: cdx_org[:organizationName], cdx_org_id: cdx_org[:organizationId])
  end
end

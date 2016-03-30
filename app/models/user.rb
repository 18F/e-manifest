class User < ActiveRecord::Base
  validates :cdx_user_id, presence: true, uniqueness: true

  has_many :manifests
  has_many :user_org_roles, class_name: 'UserOrgRole'
  has_many :roles, through: :user_org_roles
  has_many :organizations, through: :user_org_roles

  def self.find_or_create(cdx_user_id)
    find_by(cdx_user_id: cdx_user_id) || create(cdx_user_id: cdx_user_id)
  end

  def cdx_sync(dataflow = ENV['CDX_DEFAULT_DATAFLOW'])
    profiler = UserProfileBuilder.new(self, dataflow)
    profile = profiler.run
    syncer = UserProfileSyncer.new(self, profile)
    syncer.run
  end

  def role_for_org(org_name, role_name)
    user_org_roles.select do |user_org_role|
      user_org_role.organization.cdx_org_name == org_name && user_org_role.role.cdx_role_name == role_name
    end
  end

  def has_role_for_org?(org_name, role_name)
    role_for_org(org_name, role_name).any?
  end

  def org_role_status_for(org_name, role_name)
    if has_role_for_org?(org_name, role_name)
      role_for_org(org_name, role_name).first.cdx_status
    end
  end

  def tsdf_certifier?
    roles.select { |role| role.tsdf_certifier? }.any?
  end

  def state_data_download?
    roles.select { |role| role.state_data_download? }.any?
  end

  def epa_data_download?
    roles.select { |role| role.epa_data_download? }.any?
  end

  def states
    organizations.map(&:state).select(&:present?)
  end

  def state_data_download_states
    user_org_roles.map(&:state).select(&:present?)
  end

  def shares_organizations(user)
    this_orgs = organizations.pluck(:id)
    other_user_orgs = user.organizations.pluck(:id)
    (this_orgs & other_user_orgs)
  end

  def shares_organization?(user)
    shares_organizations(user).any?
  end
end

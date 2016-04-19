class UserProfileSyncer
  attr_reader :user, :profile

  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  def run
    sync_cdx_with_local
    user
  end

  private

  def sync_cdx_with_local
    User.transaction do
      add_or_update_roles
      delete_stale_roles
    end
  end

  def add_or_update_roles
    profile[:organizations].each do |org_name, cdx_org|
      sync_roles_for_org(org_name, cdx_org)
      sync_org_profile(cdx_org[:org])
    end
  end

  def sync_roles_for_org(org_name, cdx_org)
    cdx_org[:roles].each do |role_name, cdx_role|
      if !user.has_role_for_org?(org_name, role_name)
        add_org_role_to_user(cdx_org[:org], cdx_role)
      elsif user.org_role_status_for(org_name, role_name) != cdx_role[:status][:code]
        update_org_role_status(org_name, role_name, cdx_role)
      end
    end
  end

  def sync_org_profile(org_profile)
    org = Organization.from_cdx(org_profile)
    if !org.profile || org.profile.to_json != org_profile.to_json
      org.profile = org_profile
      org.save!
    end
  end

  def delete_stale_roles
    user.user_org_roles.each do |user_org_role|
      org_name = user_org_role.organization.cdx_org_name
      role_name = user_org_role.role.cdx_role_name
      unless profile[:organizations][org_name] && profile[:organizations][org_name][:roles][role_name]
        user_org_role.destroy!
      end
    end
  end

  def add_org_role_to_user(cdx_org, cdx_role)
    org = Organization.from_cdx(cdx_org)
    role = Role.from_cdx(cdx_role)
    user_org_role = UserOrgRole.new(organization: org, role: role)
    user_org_role.cdx_user_role_id = cdx_role[:userRoleId]
    user_org_role.cdx_status = cdx_role[:status][:code]
    user.user_org_roles << user_org_role
  end

  def update_org_role_status(org_name, role_name, cdx_role)
    user_org_role = user.role_for_org(org_name, role_name).first
    user_org_role.cdx_status = cdx_role[:status][:code]
    user_org_role.profile = cdx_role
    user_org_role.save!
  end
end

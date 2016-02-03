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

  def run!
    run.save!
  end

  private

  def sync_cdx_with_local
    profile[:organizations].each do |org_name, cdx_org|
      cdx_org[:roles].each do |role_name, cdx_role|
        unless user.has_role_for_org?(org_name, role_name)
          add_org_role_to_user(cdx_org, cdx_role)
        end
      end
    end
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
    user_org_role.cdx_user_role_id = cdx_role[:user_role_id]
    user_org_role.cdx_status = cdx_role[:status][:code]
    user.user_org_roles << user_org_role
  end
end

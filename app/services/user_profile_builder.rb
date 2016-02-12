class UserProfileBuilder
  attr_reader :user, :dataflow

  def initialize(user, dataflow = ENV['CDX_DEFAULT_DATAFLOW'])
    @user = user
    @dataflow = dataflow
  end

  def run
    profile = { organizations: {} }
    cdx_user_profile = build_user_profile
    profile[:user] = cdx_user_profile.perform
    organizations = fetch_organizations(profile[:user], cdx_user_profile.security_token)
    populate_roles(organizations, profile, cdx_user_profile.security_token)
    profile
  end

  private

  def build_user_profile
    CDX::UserProfile.new(user_id: user.cdx_user_id)
  end

  def fetch_organizations(user_profile, security_token)
    CDX::UserOrganizations.new(
      user_id: user.cdx_user_id,
      dataflow: dataflow,
      user: user_profile,
      security_token: security_token
    ).perform
  end

  def populate_roles(organizations, profile, security_token)
    organizations.each do |org|
      profile[:organizations][org[:organizationName]] = { org: org, roles: {} }
      roles = CDX::UserRoles.new(
        user_id: user.cdx_user_id,
        dataflow: dataflow,
        organization: org,
        user: profile[:user],
        security_token: security_token
      ).perform
      roles.each do |role|
        profile[:organizations][org[:organizationName]][:roles][role[:type][:description]] = role
      end
    end
  end
end

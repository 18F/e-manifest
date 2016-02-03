class UserProfileBuilder
  attr_reader :user, :dataflow

  def initialize(user, dataflow = ENV['CDX_DEFAULT_DATAFLOW'])
    @user = user
    @dataflow = dataflow
  end

  def run
    profile = { organizations: {} }
    user_profile = CDX::UserProfile.new(user_id: user.cdx_user_id)
    profile[:user] = user_profile.perform
    organizations = CDX::UserOrganizations.new(
      user_id: user.cdx_user_id,
      dataflow: dataflow,
      user: profile[:user],
      security_token: user_profile.security_token
    ).perform
    organizations.each do |org|
      profile[:organizations][org[:organization_name]] = { org: org, roles: {} }
      roles = CDX::UserRoles.new(
        user_id: user.cdx_user_id,
        dataflow: dataflow,
        organization: org,
        user: profile[:user],
        security_token: user_profile.security_token
      ).perform
      roles.each do |role|
        profile[:organizations][org[:organization_name]][:roles][role[:type][:description]] = role
      end
    end
    profile
  end
end

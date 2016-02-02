class UserProfileBuilder
  attr_reader :user, :dataflow

  def initialize(user, dataflow = ENV['CDX_DEFAULT_DATAFLOW'])
    @user = user
    @dataflow = dataflow
  end

  def run
    profile = { organizations: {} }
    profile[:user] = CDX::UserProfile.new(user_id: user.cdx_user_id).perform
    organizations = CDX::UserOrganizations.new(user_id: user.cdx_user_id, dataflow: dataflow).perform
    organizations.each do |org|
      profile[:organizations][org[:organization_name]] = { org: org, roles: {} }
      roles = CDX::UserRoles.new(user_id: user.cdx_user_id, dataflow: dataflow, organization: org).perform
      roles.each do |role|
        profile[:organizations][org[:organization_name]][:roles][role[:type][:description]] = role
      end
    end
    profile
  end
end

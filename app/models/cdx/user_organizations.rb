class CDX::UserOrganizations < CDX::ProfileRequest
  private

  def request
    client.call(
      :retrieve_organizations_by_dataflow,
      {   
        message: {
          securityToken: security_token,
          user: user_profile,
          dataflow: "eManifest"
        }   
      }   
    )   
  end

  def user_profile
    @user_profile ||= CDX::UserProfile.new(opts).perform
  end

  def repackage_response
    orgs_data
  end 

  def orgs_data
    @orgs_data ||= response.hash[:envelope][:body][:retrieve_user_response][:user]
  end
end

class CDX::UserProfile < CDX::ProfileRequest
  private

  def request
    client.call(
      :retrieve_user,
      {
        message: {
          securityToken: security_token,
          userId: opts[:user_id]
        }
      }
    )
  end

  def repackage_response
    user_data
  end

  def user_data
    @user_data ||= response.hash[:envelope][:body][:retrieve_user_response][:user]
  end
end

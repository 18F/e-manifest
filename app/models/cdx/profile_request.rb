class CDX::ProfileRequest < CDX::LoggedRequest
  def security_token
    @security_token ||= opts[:security_token] || CDX::System.new(output_stream).perform
  end

  def user_profile
    @user_profile ||= opts[:user] || perform_user_profile
  end

  private

  def perform_user_profile
    CDX::UserProfile.new(opts.merge(security_token: security_token), output_stream).perform
  end

  def client
    CDX::Client::Authz
  end
end

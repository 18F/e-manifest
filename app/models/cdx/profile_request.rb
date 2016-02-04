class CDX::ProfileRequest < CDX::LoggedRequest
  def security_token
    @security_token ||= opts[:security_token] || CDX::System.new(output_stream).perform
  end

  def user_profile
    @user_profile ||= opts[:user] || CDX::UserProfile.new(opts.merge(security_token: security_token)).perform
  end

  private

  def client
    CDX::Client::Authz
  end
end

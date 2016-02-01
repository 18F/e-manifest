class CDX::ProfileRequest < CDX::LoggedRequest
  private

  def security_token
    @security_token ||= CDX::System.new(output_stream).perform
  end 

  def client
    CDX::Client::Authz
  end
end

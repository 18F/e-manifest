class CDX::ProfileRequest < CDX::LoggedRequest
  def security_token
    @security_token ||= opts[:security_token] || CDX::System.new(output_stream).perform
  end 

  private

  def client
    CDX::Client::Authz
  end
end

class UserAuthenticator
  attr_reader :user_id, :password, :cdx_response, :session

  def initialize(credentials)
    @user_id = credentials[:user_id] or raise ArgumentError.new ":user_id required"
    @password = credentials[:password] or raise ArgumentError.new ":password required"
  end

  def authenticate
    @cdx_response = run_cdx_authenticator
    @session = create_session
  end

  def error_message
    cdx_response[:description]
  end

  private

  def run_cdx_authenticator
    output_stream = StreamLogger.new(Rails.logger)
    cdx_start = Time.current
    response = CDX::Authenticator.new({user_id: user_id, password: password}, output_stream).perform
    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX authenticator time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })
    response
  end

  def create_session
    if cdx_response[:token]
      user = User.find_or_create(user_id)
      session = UserSession.create(user, cdx_response[:token])
      session.set(cdx_response: cdx_response)
      session
    end
  end
end

class UserAuthenticator
  attr_reader :user_id, :session, :error_message

  def initialize(credentials, session = nil)
    @user_id = credentials[:user_id] or raise ArgumentError.new ":user_id required"
    @password = credentials[:password] or raise ArgumentError.new ":password required"
    @session = session
  end

  def authenticate
    cdx_response = run_cdx_user
    if @session
      merge_session(cdx_response)
    else
      @session = create_session(cdx_response)
    end
    @session
  end

  def authorize_signature
    cdx_response = run_cdx_authenticator
    if @session
      merge_session(cdx_response)
    else
      @session = create_session(cdx_response)
    end
    @session
  end

  private

  def run_cdx_user
    output_stream = StreamLogger.new(Rails.logger)
    cdx_start = Time.current
    begin
      response = CDX::User.new({user_id: user_id, password: @password}, output_stream).perform
    rescue Savon::SOAPFault => error
      response = CDX::HandleError.new(error, output_stream).perform
    end
    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX::User time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })
    response
  end

  def run_cdx_authenticator
    output_stream = StreamLogger.new(Rails.logger)
    cdx_start = Time.current
    response = CDX::Authenticator.new({user_id: user_id, password: @password}, output_stream).perform
    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX::Authenticator time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })
    response
  end

  def create_session(cdx_response)
    session = nil
    if cdx_response[:description]
      @error_message = cdx_response[:description]
    else
      user = sync_user
      unless @error_message
        session = UserSession.create(user, cdx_response)
      end
    end
    session
  end

  def merge_session(cdx_response)
    @session.user = sync_user
    if @error_message
      @session = nil
    else
      @session.merge_cdx(cdx_response)
    end
  end

  def sync_user
    user = User.find_or_create(user_id)
    user.cdx_sync
    user.reload
    unless user.active_cdx?
      @error_message = 'Account is not yet active'
    end
    user
  end
end

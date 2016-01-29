module AuthParams
  def auth_params
    params.fetch(:token, {}).permit(:user_id, :password, :back)
  end

  private

  def authenticate_with_cdx
    authenticator = UserAuthenticator.new(auth_params, user_session)
    if authenticator.authenticate
      authenticator.session
    else
      @auth_error = authenticator.error_message
    end
  end

  def authorize_signature_with_cdx
    authenticator = UserAuthenticator.new(auth_params, user_session)
    if authenticator.authorize_signature
      authenticator.session
    else
      @auth_error = authenticator.error_message
    end
  end
end

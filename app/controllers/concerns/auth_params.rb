module AuthParams
  def auth_params
    params.fetch(:token, {}).permit(:user_id, :password)
  end

  private

  def authenticate_with_cdx
    authenticator = UserAuthenticator.new(auth_params)
    if authenticator.authenticate
      authenticator.session
    else
      @auth_error = authenticator.error_message
    end
  end
end

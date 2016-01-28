module UserAuthenticatorHelper
  def login_as(user, cdx_response = nil)
    UserSession.create(user, cdx_response)
  end

  def mock_authenticated_session
    user_session = mock_user_authenticator_pass
    allow_any_instance_of(ApplicationController).to receive(:user_session).and_return(user_session)
    user_session
  end

  def mock_user_authenticator_pass
    user = create(:user)
    session = UserSession.create(user, { token: SecureRandom.hex })
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(session)
    allow_any_instance_of(UserAuthenticator).to receive(:session).and_return(session)
    allow_any_instance_of(UserAuthenticator).to receive(:cdx_response).and_return(session.cdx_auth_response)
    session
  end

  def mock_user_authenticator_fail
    user = create(:user)
    session = UserSession.create(user, { token: SecureRandom.hex })
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:cdx_response).and_return({description: 'Bad user_id or password'})
    session
  end
end

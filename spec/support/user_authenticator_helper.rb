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
    session = UserSession.create(user, { firstName: 'Jane', lastName: 'Doe' })
    cdx_signature = { token: SecureRandom.hex, question: { question_id: 123, question_text: 'color?' }, activity_id: SecureRandom.hex }
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(session)
    allow_any_instance_of(UserAuthenticator).to receive(:authorize_signature).and_return(session.merge_cdx(cdx_signature))
    allow_any_instance_of(UserAuthenticator).to receive(:session).and_return(session)
    allow_any_instance_of(UserAuthenticator).to receive(:error_message).and_return(nil)
    session
  end

  def mock_user_authenticator_fail
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:authorize_signature).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:error_message).and_return('Bad user_id or password')
  end
end

require 'rails_helper'

describe UserAuthenticator do
  describe 'workflow' do
    it '#authenticate' do
      mock_user_authenticator_pass
      authenticator = UserAuthenticator.new(user_id: 'user', password: 'pass')
      expect(authenticator.authenticate).to be_a UserSession
    end

    it '#cdx_response' do
      mock_user_authenticator_pass
      authenticator = UserAuthenticator.new(user_id: 'user', password: 'pass')
      authenticator.authenticate
      expect(authenticator.session.cdx).to_not be_nil
    end

    it '#error_message' do
      mock_user_authenticator_fail
      authenticator = UserAuthenticator.new(user_id: 'nope', password: 'never')
      expect(authenticator.authenticate).to be_nil
      expect(authenticator.error_message).to eq 'Bad user_id or password'
    end

    it '#new requires user_id' do
      expect {
        UserAuthenticator.new(password: 'foo')
      }.to raise_error ArgumentError
    end

    it '#new requires password' do
      expect {
        UserAuthenticator.new(user_id: 'foo')
      }.to raise_error ArgumentError
    end
  end

  describe 'user session' do
    it 'merges new cdx response with existing session' do
      user_session = mock_user_authenticator_pass
      authenticator = UserAuthenticator.new({user_id: 'user', password: 'pass'}, user_session)
      expect(authenticator.authorize_signature).to be_a UserSession
      expect(authenticator.authorize_signature.token).to eq user_session.token
      expect(authenticator.authorize_signature.cdx_token).to_not be_nil
    end
  end
end

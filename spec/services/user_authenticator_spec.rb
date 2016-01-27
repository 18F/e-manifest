require 'rails_helper'
include UserAuthenticatorHelper

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
      expect(authenticator.cdx_response[:token]).to_not be_nil
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
end

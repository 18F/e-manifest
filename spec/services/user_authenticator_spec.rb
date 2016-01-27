require 'rails_helper'

describe UserAuthenticator do
  describe 'workflow' do
    it '#authenticate' do
      authenticator = UserAuthenticator.new(user_id: 'user', password: 'pass')
      expect(authenticator.authenticate).to be_a UserSession
    end

    it '#cdx_response' do
      authenticator = UserAuthenticator.new(user_id: 'user', password: 'pass')
      authenticator.authenticate
      expect(authenticator.cdx_response[:token]).to_not be_nil
    end

    it '#error_message' do
      authenticator = UserAuthenticator.new(user_id: 'user', password: 'pass', mock_error: true)
      expect(authenticator.authenticate).to eq nil
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

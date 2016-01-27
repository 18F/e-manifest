require 'rails_helper'

describe 'Auth' do
  describe 'login' do
    it 'returns form on GET' do
      get "/login"
      expect(response.body).to include 'Username'
    end

    it 'redirects on POST failure' do
      mock_user_authenticator_fail
      post "/login", { token: { user_id: 'foo', password: 'bar' } }
      expect(response).to redirect_to login_path
      expect(flash[:error]).to eq 'Bad user_id or password'
    end

    it 'redirects on POST success' do
      mock_user_authenticator_pass
      post "/login?back=#{new_submission_path}", { token: { user_id: 'foo', password: 'bar' } }
      expect(response).to redirect_to new_submission_path
      expect(flash[:message]).to eq 'Success!'
    end
  end

  describe 'logout' do
    it 'clears session' do
      user_session = mock_user_authenticator_pass
      post "/login?back=#{new_submission_path}", { token: { user_id: 'foo', password: 'bar' } }
      expect(session[:user_session_id]).to eq user_session.token

      get "/logout"
      expect(response).to redirect_to root_path
      expect(flash[:message]).to eq 'You have been signed out.'
      expect(session[:user_session_id]).to be_nil
      expect(UserSession.new(user_session.token).user).to be_nil
    end
  end
end

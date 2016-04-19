require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      render json: user_session
    end
  end

  describe 'user session' do
    it 'extends life of session each time user makes a request' do
      current_session = mock_authenticated_session
      initial_session_time = current_session.updated_at
      sleep 1
      get :index
      expect(UserSession.new(current_session.token).updated_at).to be > initial_session_time
    end

    it 'respects Authorization header' do
      current_session = mock_user_authenticator_pass
      set_request_headers(Authorization: "Bearer #{current_session.token}")
      get :index
      current_session_hash = JSON.parse(current_session.to_json, symbolize_names: true)
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_response[:session]).to eq(current_session_hash[:session])
    end
  end
end

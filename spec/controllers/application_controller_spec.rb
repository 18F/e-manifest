require 'rails_helper'

describe ApplicationController do
  before :each do
    @current_session = mock_authenticated_session
  end

  controller do
    def index
      render inline: 'hello world'
    end
  end

  describe 'user session' do
    it 'extends life of session each time user makes a request' do
      initial_session_time = @current_session.updated_at
      sleep 1
      get :index
      expect(UserSession.new(@current_session.token).updated_at).to be > initial_session_time
    end
  end
end

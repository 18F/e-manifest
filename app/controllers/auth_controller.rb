class AuthController < ApplicationController
  include AuthParams

  def index
    if params[:back]
      session[:back] = params[:back]
    end
  end

  def login
    if auth_params
      authenticate
    else
      flash[:error] = 'Missing user_id and/or password'
      redirect_to login_url
    end 
  end

  def logout
    if authenticated?
      if user_session
        user_session.expire
      end
      session.delete(:user_session_id)
      flash[:notice] = 'You have been signed out.'
      redirect_to root_path
    else
      flash[:error] = 'You were not logged in.'
      redirect_to root_path
    end
  end

  def profile
  end

  private

  def authenticate
    user_session = authenticate_with_cdx
    if @auth_error
      flash[:error] = @auth_error
      redirect_to login_url
    else
      session[:user_session_id] = user_session.token
      flash[:notice] = 'Success!'
      previous_url = fetch_previous_url
      session.delete(:back)
      redirect_to previous_url
    end
  end

  def fetch_previous_url
    params[:back] || params[:token][:back] || session[:back] || root_path
  end
end

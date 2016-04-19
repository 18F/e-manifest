class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  helper_method :current_user, :user_session

  after_action :extend_session

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def extend_session
    if user_session
      user_session.touch
    end
  end

  def current_user
    @current_user ||= find_current_user
  end

  def authenticate_user!
    unless authenticated?
      flash[:error] = 'You must be logged in to access this page.'
      session[:back] = request.original_url
      redirect_to login_path(back: session[:back])
    end
  end

  def find_current_user
    if user_session
      user_session.user
    end
  end

  def user_session
    if session[:user_session_id]
      UserSession.new(session[:user_session_id])
    elsif authorization_token?
      UserSession.new(authorization_token)
    elsif params[:token] && params[:token].is_a?(String)
      UserSession.new(params[:token])
    end
  end

  def authenticated?
    current_user.present?
  end

  def authorization_token?
    request.headers['Authorization'] && request.headers['Authorization'].match(/^Bearer (\S+)/i)
  end

  def authorization_token
    request.headers['Authorization'].match(/^Bearer (\S+)/i)[1]
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end

class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    response = CDX::Authenticator.new(auth_params).perform
    session[:system_session_token] = response[:token]
    response[:token] = session.id
    render json: response.to_json
  end
end

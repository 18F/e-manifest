class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    response = CDX::Authenticator.new(auth_params).perform

    if response[:token]
      session[:system_session_token] = response[:token]
      response[:token] = session.id
      render json: response.to_json, status: 200
    else
      render json: {
        message: "Authentication failed",
        errors: response[:description]
      }.to_json, status: 401
    end
  end
end

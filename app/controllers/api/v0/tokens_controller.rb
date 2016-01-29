class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    user_session = authorize_signature_with_cdx

    if @auth_error
      render json: { message: "Authentication failed", errors: @auth_error }.to_json, status: 401
    else
      response = user_session.signature_response
      render json: response.to_json, status: 200
    end
  end
end

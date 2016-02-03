class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    if params[:authenticate]
      authentication_token
    else
      signature_token
    end
  end

  private

  def authentication_token
    user_session = authenticate_with_cdx

    if @auth_error
      render json: { message: "Authentication failed", errors: @auth_error }.to_json, status: 401
    else
      render json: { token: user_session.token }, status: 200
    end
  end

  def signature_token
    user_session = authorize_signature_with_cdx

    if @auth_error
      render json: { message: "Authentication failed", errors: @auth_error }.to_json, status: 401
    else
      response = user_session.signature_response
      render json: response.to_json, status: 200
    end
  end
end

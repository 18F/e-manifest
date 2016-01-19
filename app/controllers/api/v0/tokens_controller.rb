class Api::V0::TokensController < ApiController
  def create
    body = request.body.read
      authentication = JSON.parse(body)
      response = CDX::Authenticator.new(authentication).perform
      session[:system_session_token] = response[:token]
      response[:token] = session.id
      render json: response.to_json
  end
end

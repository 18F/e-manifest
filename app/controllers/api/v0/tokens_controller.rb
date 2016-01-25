class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    cdx_start = Time.now
    response = CDX::Authenticator.new(auth_params).perform
    cdx_stop = Time.now
    Rails.logger.debug(ANSI.blue{ "  CDX authenticator time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    if response[:token]
      user_token = store_signature_token(response[:token])
      response[:token] = user_token
      render json: response.to_json, status: 200
    else
      render json: {
        message: "Authentication failed",
        errors: response[:description]
      }.to_json, status: 401
    end
  end

  def store_signature_token(cdx_token)
    user_token = SecureRandom.uuid
    redis = Redis.new
    redis.set(user_token, cdx_token)
    user_token
  end
end

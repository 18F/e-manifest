class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    response = authenticate_with_cdx

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

  private

  def authenticate_with_cdx
    output_stream = StreamLogger.new(Rails.logger)
    cdx_start = Time.current
    response = CDX::Authenticator.new(auth_params, output_stream).perform
    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX authenticator time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })
    response
  end

  def store_signature_token(cdx_token)
    user_token = SecureRandom.uuid
    redis = Redis.new
    redis.set(user_token, cdx_token)
    user_token
  end
end

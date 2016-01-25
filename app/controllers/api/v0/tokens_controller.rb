class Api::V0::TokensController < ApiController
  include AuthParams

  def create
    cdx_start = Time.now
    response = CDX::Authenticator.new(auth_params).perform
    cdx_stop = Time.now
    Rails.logger.debug(ANSI.blue{ "  CDX authenticator time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    if response[:token]
      response[:token] = Base64.strict_encode64(response[:token])
      render json: response.to_json, status: 200
    else
      render json: {
        message: "Authentication failed",
        errors: response[:description]
      }.to_json, status: 401
    end
  end
end

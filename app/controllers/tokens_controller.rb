class TokensController < ApplicationController
  include AuthParams

  def new
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
  end

  def create
    output_stream = StreamLogger.new(Rails.logger)
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
    response = CDX::Authenticator.new(auth_params, output_stream).perform

    if response[:question] && response[:token]
      response[:token] = store_session_token(response[:token])
      redirect_to new_manifest_signature_path(@manifest.uuid, response: response)
    else
      flash[:error] = response[:description]
      render :new
    end
  end

  private

  def store_session_token(cdx_token)
    user = User.find_or_create(auth_params[:user_id])
    session = UserSession.create(user, cdx_token)
    session.token
  end
end

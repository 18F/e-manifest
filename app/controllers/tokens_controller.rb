class TokensController < ApplicationController
  include AuthParams

  def new
    find_manifest
  end

  def create
    user_session = authenticate_with_cdx
    find_manifest

    if @auth_error
      flash[:error] = @auth_error
      render :new, status: 401
    else
      response = user_session.cdx_auth_response.dup
      response[:token] = user_session.token
      redirect_to new_manifest_signature_path(@manifest.uuid, response: response)
    end
  end

  private

  def find_manifest
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
  end
end

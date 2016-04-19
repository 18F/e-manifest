class SignOrUploadController < ApplicationController
  def new
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
  end
end

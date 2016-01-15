class SignOrUploadController < ApplicationController
  def new
    @manifest = Manifest.find(params[:manifest_id])
  end
end

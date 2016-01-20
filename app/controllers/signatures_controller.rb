class SignaturesController < ApplicationController
  def new
    @manifest = Manifest.find(params[:manifest_id])
  end

  def create

  end
end

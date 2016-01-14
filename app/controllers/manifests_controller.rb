class ManifestsController < ApplicationController
  def new
  end

  def index
    @manifests = Manifest.all
  end

  def show
    @manifest = Manifest.find params[:id]
  end
end

class ManifestsController < ApplicationController
  def new
  end

  def index
    @manifests = Manifest.all
  end
end

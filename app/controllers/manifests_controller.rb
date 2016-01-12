class ManifestsController < ApplicationController
  def new
  end

  def index
    @manifests = Manifest.authorized_search({public: true}).response.records.to_a
  end
end

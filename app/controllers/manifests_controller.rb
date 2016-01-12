class ManifestsController < ApplicationController
  def new
  end

  def index
    result = HTTParty.get(api_v0_manifests_search_url, headers: { "Content-Type" =>'application/json'})
    @manifests = JSON.parse(result.body)
  end
end

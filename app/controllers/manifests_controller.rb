class ManifestsController < ApplicationController
  include ManifestParams

  def new
  end

  def create
    @manifest = Manifest.new(content: manifest_params)

    if @manifest.save!
      tracking_number = manifest_params[:generator][:manifest_tracking_number]
      flash[:notice] = "Manifest #{tracking_number} submitted successfully."
      redirect_to new_manifest_sign_or_upload_path(@manifest)
    end
  end

  def index
    if params[:q] || params[:aq]
      @manifests = Manifest.authorized_search(params).records.to_a
    else
      @manifests = Manifest.authorized_search({public: true}).records.to_a
    end
  end

  def show
    @manifest = Manifest.find(params[:id])
  end
end

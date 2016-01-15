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
    @manifests = Manifest.authorized_search({public: true}).records.to_a
  end

  def show
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:id])
  end
end

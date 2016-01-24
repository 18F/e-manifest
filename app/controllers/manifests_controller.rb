class ManifestsController < ApplicationController
  include ManifestParams

  def new
  end

  def create
    if validate_manifest(manifest_params)
      @manifest = Manifest.new(content: manifest_params)

      if @manifest.save!
        @manifest.reload
        tracking_number = @manifest.tracking_number
        flash[:notice] = "Manifest #{tracking_number} submitted successfully."
        redirect_to new_manifest_sign_or_upload_path(@manifest.uuid)
      end
    else
      render 'new'
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
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:id])
  end

  private

  def validate_manifest(content)
    validator = ManifestValidator.new(content)
    unless validator.run
      puts content.pretty_inspect
      @errors = validator.error_messages
    end
    !validator.errors.any?
  end
end

class Api::V0::ManifestsController < ApiController
  def search
    if !params[:q] && !params[:aq]
      render json: {message: 'Missing q or aq param'}, status: 400
    else
      render json: ManifestSearchSerializer.new(Manifest.authorized_search(params)).to_json(root: false)
    end
  end

  def create
    @manifest = Manifest.new(content: manifest_params)

    if @manifest.save!
      tracking_number = manifest_params[:manifest_tracking_number]
      render json: {
        message: "Manifest #{tracking_number} submitted successfully.",
      }.to_json, status: 201
    else
      render json: {
        message: "Validation failed",
        errors: @manifest.errors.full_messages
      }.to_json, status: 422
    end
  end

  def show
    begin
      manifest = find_manifest
    rescue ActiveRecord::RecordNotFound => _error
      render json: {}, status: 404
      return
    end

    render json: ManifestSerializer.new(manifest).to_json(root: false)
  end

  def update
    begin
      manifest = find_manifest

      patch = JSON.parse(request.body.read)
      patch_json = patch.to_json

      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json);
      manifest.update_column(:content, new_json)

      render json: ManifestSerializer.new(manifest).to_json(root: false)
    rescue ActiveRecord::RecordNotFound => _error
      status 404
    end
  end

  private

  def manifest_params
    params.require(:manifest).permit(
      :manifest_tracking_number,
    )
  end

  def find_manifest
    if params[:id] || params[:uuid]
      find_manifest_by_id
    elsif params[:tracking_number]
      find_manifest_by_tracking_number
    end
  end

  def find_manifest_by_id
    Manifest.find_by!(uuid: (params[:id] || params[:uuid]))
  end

  def find_manifest_by_tracking_number
    Manifest.find_by!("content -> 'generator' ->> 'manifest_tracking_number' = ?", params[:tracking_number])
  end
end

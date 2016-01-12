class Api::V0::ManifestsController < ApplicationController
  def search
    if !params[:q] && !params[:aq]
      manifests = Manifest.all
      render json: ActiveModel::ArraySerializer.new(manifests, each_serializer: ManifestSerializer)
    else
      render json: Manifest.authorized_search(params).response[:hits].to_json
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
      if params[:id]
        manifest = Manifest.find(params[:id])
      elsif params[:tracking_number]
        manifest = Manifest.find_by!("content -> 'generator' ->> 'manifest_tracking_number' = ?", params[:tracking_number])
      end
    rescue ActiveRecord::RecordNotFound => _error
      render json: {}, status: 404
      return
    end

    render json: manifest.to_json
  end

  def update
    begin
      if params[:id]
        manifest = Manifest.find(params[:id])
      elsif params[:tracking_number]
        manifest = Manifest.find_by!("content -> 'generator' ->> 'manifest_tracking_number' = ?", params[:tracking_number])
      end

      patch = JSON.parse(request.body.read)
      patch_json = patch.to_json

      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json);
      manifest.update_column(:content, new_json)

      render json: manifest.to_json
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
end

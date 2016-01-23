class Api::V0::ManifestsController < ApiController
  def search
    if !params[:q] && !params[:aq]
      render json: {message: 'Missing q or aq param'}, status: 400
    else
      render json: ManifestSearchSerializer.new(Manifest.authorized_search(params)).to_json
    end
  end

  def validate
    manifest_content = read_body_as_json
    unless performed?
      if validate_manifest(manifest_content)
        render json: {message: "Manifest structure is valid"}, status: 200
      end
    end
  end

  def create
    manifest_content = read_body_as_json
    unless performed?
      if validate_manifest(manifest_content)
        @manifest = Manifest.new(content: manifest_content)

        if @manifest.save
          tracking_number = @manifest.tracking_number
          render json: {
            message: "Manifest #{tracking_number} submitted successfully.",
          }, status: 201
        else
          render json: {
            message: "Validation failed",
            errors: @manifest.errors.full_messages.to_sentence
          }, status: 422
        end
      end
    end
  end

  def show
    manifest = find_manifest
    render json: ManifestSerializer.new(manifest).to_json
  end

  def update
    manifest = find_manifest
    patch = read_body_as_json

    unless performed?
      patch_json = patch.to_json
      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json)

      manifest.update_column(:content, new_json)

      render json: ManifestSerializer.new(manifest).to_json
    end
  end

  private

  def validate_manifest(content)
    validator = ManifestValidator.new(content)
    unless validator.run
      render json: {
        message: "Validation failed",
        errors: validator.error_messages
      }, status: 422
    end
    !validator.errors.any?
  end
end

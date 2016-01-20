class Api::V0::ManifestsController < ApiController
  include ManifestParams

  def search
    if !params[:q] && !params[:aq]
      render json: {message: 'Missing q or aq param'}, status: 400
    else
      render json: ManifestSearchSerializer.new(Manifest.authorized_search(params)).to_json
    end
  end

  def validate
    begin
      manifest_content = JSON.parse(request.body.read)
      if validate_manifest(manifest_content)
        render json: {message: "Manifest structure is valid"}, status: 200
      end
    rescue JSON::ParserError => error
      render json: {message: "Invalid JSON in request: #{error}"}, status: 400
    end
  end

  def create
    if validate_manifest(manifest_params)
      @manifest = Manifest.new(content: manifest_params)

      if @manifest.save
        tracking_number = manifest_params[:manifest_tracking_number]
        render json: {
          message: "Manifest #{tracking_number} submitted successfully.",
        }.to_json, status: 201
      else
        render json: {
          message: "Validation failed",
          errors: @manifest.errors.full_messages.to_sentence
        }.to_json, status: 422
      end
    end
  end

  def show
    begin
      manifest = find_manifest
    rescue ActiveRecord::RecordNotFound => _error
      render json: {}, status: 404
      return
    end

    render json: ManifestSerializer.new(manifest).to_json
  end

  def update
    begin
      manifest = find_manifest

      patch = JSON.parse(request.body.read)
      patch_json = patch.to_json

      manifest_content_json = manifest[:content].to_json
      new_json = JSON.patch(manifest_content_json, patch_json);
      manifest.update_column(:content, new_json)

      render json: ManifestSerializer.new(manifest).to_json
    rescue ActiveRecord::RecordNotFound => _error
      status 404
    end
  end

  private

  def find_manifest
    Manifest.find_by_uuid_or_tracking_number!(params[:id])
  end

  def validate_manifest(content)
    validator = ManifestValidator.new(content)
    unless validator.run
      render json: {
        message: "Validation failed",
        errors: validator.error_messages
      }.to_json, status: 422
    end
    !validator.errors.any?
  end
end

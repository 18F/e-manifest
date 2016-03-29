class Api::V0::ManifestsController < ApiController
  include SearchParams

  rescue_from ActiveRecord::RecordNotFound, with: :manifest_not_found_error

  def search
    if !params[:q] && !params[:aq]
      render json: {message: 'Missing q or aq param'}, status: 400
    else
      render json: ManifestSearchSerializer.new(Manifest.authorized_search(params)[:es_response]).to_json
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
    authenticate_user!
    # TODO authz based on roles
    unless performed?
      manifest_content = read_body_as_json
    end

    unless performed?
      if validate_manifest(manifest_content)
        @manifest = Manifest.new(content: manifest_content, user: current_user)
        create_manifest(@manifest)
      end
    end
  end

  def show
    manifest = find_manifest
    if has_permission_to_view?(manifest)
      unless performed?
        render json: ManifestSerializer.new(manifest).to_json
      end
    else
      unless performed?
        render json: {
          message: "Permission denied",
          errors: "You do not have permission to view this manifest."
        }, status: 403
      end
    end
  end

  def update
    manifest = find_manifest
    if has_permission_to_update?(manifest)
      if (patch = read_body_as_json)
        patch_json = patch.to_json
        manifest_content_json = manifest[:content].to_json
        new_json = JSON.patch(manifest_content_json, patch_json)

        manifest.update_column(:content, new_json)

        render json: ManifestSerializer.new(manifest).to_json
      end
    else
      render json: {
        message: "Permission denied",
        errors: "You do not have permission to update this manifest."
      }, status: 403
    end
  end

  private

  def create_manifest(manifest)
    if manifest.save
      manifest.reload
      render json: {
        message: "Manifest #{manifest.tracking_number} submitted successfully.",
        location: api_v0_manifest_url(manifest.uuid)
      }, status: 201
    else
      render json: {
        message: "Validation failed",
        errors: manifest.errors.full_messages.to_sentence
      }, status: 422
    end
  end

  def validate_manifest(content)
    run_validator(ManifestValidator.new(content))
  end

  def has_permission_to_update?(manifest)
    if !authenticated?
      false
    # TODO more complicated authz based on roles+orgs
    elsif manifest.user == current_user
      true
    else
      false
    end
  end

  def has_permission_to_view?(manifest)
    if manifest.is_public?
      true
    elsif authenticated?
      authorize manifest, :can_view?
    else
      false
    end
  end
end

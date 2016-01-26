class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    signature_request = read_body_as_json(symbolize_names: true)

    if validate_signature(signature_request)
      cdx_response = ManifestSigner.new(signature_request.merge(manifest: manifest)).perform

      unless performed?
        render(json: cdx_response.to_json, status: status_code(cdx_response))
      end
    end
  end

  private

  def validate_signature(content)
    validator = SignatureValidator.new(content)

    if validator.run == false
      render json: {
        message: "Validation failed",
        errors: validator.error_messages
      }, status: 422
    end

    !validator.errors.any?
  end

  def status_code(cdx_response)
    if cdx_response.key?(:document_id)
      200
    else
      422
    end
  end
end

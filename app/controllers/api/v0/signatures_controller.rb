class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    signature_request = prep_signature_request(manifest)
    cdx_response = ManifestSigner.new(signature_request).perform

    unless performed?
      render(json: cdx_response.to_json, status: status_code(cdx_response))
    end
  end

  private

  def prep_signature_request(manifest)
    signature_request = read_body_as_json(symbolize_names: true)
    signature_request.merge(manifest: manifest)
  end

  def status_code(cdx_response)
    if cdx_response.key?(:document_id)
      200
    else
      422
    end
  end
end

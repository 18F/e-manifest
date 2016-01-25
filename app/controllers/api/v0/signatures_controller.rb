class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    signature_request = prep_signature_request(manifest)

    cdx_start = Time.now
    cdx_response = CDX::Manifest.new(signature_request).sign
    cdx_stop = Time.now
    Rails.logger.debug(ANSI.blue{ "  CDX signature time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    status = update_manifest(cdx_response, signature_request, manifest)

    render(json: cdx_response.to_json, status: status) unless performed?
  end

  private

  def prep_signature_request(manifest)
    signature_request = read_body_as_json(symbolize_names: true)
    signature_request[:manifest_content] = manifest[:content].to_json
    if signature_request[:token]
      signature_request[:token] = Base64.strict_decode64(signature_request[:token])
    end
    signature_request
  end

  def update_manifest(cdx_response, signature_request, manifest)
    if cdx_response.key?(:document_id)
      manifest.document_id = cdx_response[:document_id]
      manifest.activity_id = signature_request[:activity_id]
      manifest.save!
      status = 200
    else
      status = 422
    end
    status
  end
end

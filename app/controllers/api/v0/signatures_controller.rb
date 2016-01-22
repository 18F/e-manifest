class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    signature_request = prep_signature_request(manifest)

    cdx_start = Time.current
    cdx_response = CDX::Manifest.new(signature_request).sign
    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX signature time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    status = update_manifest(cdx_response, signature_request, manifest)

    unless performed?
      render(json: cdx_response.to_json, status: status)
    end
  end

  private

  def prep_signature_request(manifest)
    signature_request = read_body_as_json(symbolize_names: true)
    signature_request[:manifest_content] = manifest.content.to_json
    if signature_request[:token]
      signature_request[:token] = lookup_signature_token(signature_request[:token])
    else
      render json: { message: "Missing signature token" }, status: 403
    end
    signature_request
  end

  def lookup_signature_token(user_token)
    redis = Redis.new
    redis.get(user_token)
  end

  def update_manifest(cdx_response, signature_request, manifest)
    if cdx_response.key?(:document_id)
      manifest.document_id = cdx_response[:document_id]
      manifest.activity_id = signature_request[:activity_id]
      manifest.signed_at = Time.current
      manifest.save!
      200
    else
      422
    end
  end
end

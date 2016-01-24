class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    sign_request = read_body_as_json(symbolize_names: true)

    manifest_content = manifest[:content].to_json
    sign_request[:manifest_content] = manifest_content

    if sign_request[:token]
      sign_request[:token] = Base64.strict_decode64(sign_request[:token])
    end

    response = CDX::Manifest.new(sign_request).sign

    if (response.key?(:document_id))
      manifest[:document_id] = response[:document_id]
      manifest[:activity_id] = sign_request[:activity_id]
      manifest.save!
      render(json: response.to_json, status: 200) unless performed?
    else
      render(json: response.to_json, status: 422) unless performed?
    end
  end
end

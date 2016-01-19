class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])

    if manifest.nil?
      status 404
      return
    end

    sign_request = JSON.parse(request.body.read)
    manifest_content = manifest[:content].to_json
    sign_request[:manifest_content] = manifest_content
    system_session_token = session[:system_session_token]
    sign_request["token"] = system_session_token

    response = CDX::Manifest.new(sign_request).sign

    if (response.key?(:document_id))
      manifest[:document_id] = response[:document_id]
      manifest[:activity_id] = sign_request["activity_id"]
      manifest.save
    end

    render json: response.to_json
  end

  private

  def find_manifest(id)
    Manifest.find_by_uuid_or_tracking_number!(id)
  end
end

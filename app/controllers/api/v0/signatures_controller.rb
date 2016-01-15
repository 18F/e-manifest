class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest_by_id_or_tracking_number(params[:manifest_id])

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

  def find_manifest_by_id_or_tracking_number(id)
    Manifest.where(id: id).first ||
      Manifest.where("content -> 'generator' ->> 'manifest_tracking_number' = ?", id).first
  end
end

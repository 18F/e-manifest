class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  rescue_from ManifestNotFound, with: :manifest_not_found_error

  private

  def find_manifest(id = params[:id])
    Manifest.find_by_uuid_or_tracking_number!(id)
  end

  def manifest_not_found_error
    render json: {
      message: "Manifest not found",
      errors: ["No manifest for id #{params[:id]}"]
    }, status: 404
  end

  def read_body_as_json(opts = {})
    begin
      deserialized = JSON.parse(request.body.read, opts)
    rescue JSON::ParserError => error
      render json: {message: "Invalid JSON in request: #{error}"}, status: 400
    end
  end
end

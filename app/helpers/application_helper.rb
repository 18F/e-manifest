module ApplicationHelper
  def upload_path
    if params[:manifest_id]
      manifest_manifest_uploads_path(params[:manifest_id])
    else
      manifest_uploads_path
    end
  end
end

class ManifestUploadsController < ApplicationController
  def new
  end

  def create
    upload = params[:manifest][:upload]
    file = File.open(upload.tempfile).read
    encoded_file = Base64.encode64(file)
    image_details = {
      file_name: upload.original_filename,
      content: encoded_file,
      content_type: upload.content_type,
    }

    if params[:manifest_id]
      manifest = Manifest.find(params[:manifest_id])
      manifest.content[:image] = image_details
    else
      manifest = Manifest.new(content: { image: image_details })
    end

    if manifest.save
      flash[:notice] = "Upload for manifest #{manifest.tracking_number} submitted successfully."
      redirect_to root_path
    end
  end
end

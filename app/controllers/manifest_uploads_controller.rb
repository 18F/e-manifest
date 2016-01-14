class ManifestUploadsController < ApplicationController
  def new
  end

  def create
    manifest = find_or_initialize_manifest

    if manifest.save
      flash[:notice] = "Upload for manifest #{manifest.tracking_number} submitted successfully."
      redirect_to root_path
    end
  end

  private

  def find_or_initialize_manifest
    if params[:manifest_id]
      manifest = Manifest.find(params[:manifest_id])
      manifest.content[:image] = image_details
      manifest
    else
      Manifest.new(content: { image: image_details })
    end
  end

  def image_details
    {
      file_name: upload.original_filename,
      content: encoded_file,
      content_type: upload.content_type,
    }

  end

  def upload
    @_upload ||= params[:manifest][:upload]
  end

  def encoded_file
    Base64.encode64(file)
  end

  def file
    File.open(upload.tempfile).read
  end
end

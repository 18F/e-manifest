class ManifestUploadsController < ApplicationController
  def new
    @manifest = find_or_initialize_manifest
  end

  def create
    manifest = update_manifest(find_or_initialize_manifest)

    if manifest.save
      flash[:notice] = "Upload for manifest #{manifest.tracking_number} submitted successfully."
      redirect_to root_path
    else
      flash[:notice] = manifest.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def find_or_initialize_manifest
    if params[:manifest_id]
      Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
    else
      Manifest.new
    end
  end

  def update_manifest(manifest)
    if params[:manifest_id]
      manifest.tap { |object| object.content[:uploaded_file] = image_details }
    else
      manifest.tap { |object| object.content = parsed_upload_params }
    end
  end

  def parsed_upload_params
    manifest_upload_params.merge(uploaded_file: image_details)
  end

  def manifest_upload_params
    params.require(:manifest).permit(
      generator: [:manifest_tracking_number],
      uploaded_file: [:content, :content_type, :file_name]
    )
  end

  def image_details
    {
      file_name: upload.original_filename,
      content: encoded_file,
      content_type: upload.content_type,
    }

  end

  def upload
    @_upload ||= params[:manifest][:uploaded_file]
  end

  def encoded_file
    Base64.encode64(file)
  end

  def file
    File.open(upload.tempfile).read
  end
end

class ManifestUploadsController < ApplicationController
  def new
    @manifest = find_or_initialize_manifest
  end

  def create
    authenticate_user!

    @manifest = update_manifest(find_or_initialize_manifest)

    if !upload_missing? && @manifest.save
      flash[:notice] = "Upload for manifest #{@manifest.tracking_number} submitted successfully."
      redirect_to root_path
    else
      flash[:error] = @manifest.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
    manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
    file_details = manifest.content['uploaded_file']
    decoded_file = Base64.decode64(file_details['content'])
    send_data(
      decoded_file,
      type: 'application/pdf; charset=utf-8; header=present',
      filename: file_details['file_name'],
      disposition: 'attachment'
    )
  end

  private

  def find_or_initialize_manifest
    if params[:manifest_id]
      Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
    else
      Manifest.new(user: current_user)
    end
  end

  def update_manifest(manifest)
    if params[:manifest_id]
      manifest.tap { |object| object.content[:uploaded_file] = image_details }
    else
      manifest.tap { |object| object.content = parsed_upload_params }
    end
  end

  def upload_missing?
    if params[:manifest][:uploaded_file].blank?
      @manifest.errors.add(:file_upload, "must be present.")
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
      file_name: upload.try(:original_filename),
      content: encoded_file,
      content_type: upload.try(:content_type),
    }
  end

  def upload
    @_upload ||= params[:manifest][:uploaded_file]
  end

  def encoded_file
    if file
      Base64.encode64(file)
    end
  end

  def file
    if upload
      @_file ||= File.open(upload.tempfile).read
    end
  end
end

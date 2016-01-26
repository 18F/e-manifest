module ManifestHelper
  def file_upload_button(manifest)
    if manifest.content['uploaded_file'].present?
      link_to 'Download Scanned Image', manifest_manifest_upload_path(manifest_id: @manifest.uuid), class: 'usa-button usa-button-outline'
    else
      'No scanned image available for this manifest.'
    end
  end
end

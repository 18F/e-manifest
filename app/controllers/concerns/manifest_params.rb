module ManifestParams
  def manifest_params
    params.fetch(:manifest, {})
  end
end

module ManifestParams
  def manifest_params
    deep_reject!( params.fetch(:manifest, {}) ) { |k, v| v.blank? }
  end

  private

  def deep_reject!(hash, &block)
    hash.each do |k, v|
      deep_reject!(v, &block) if (v.is_a?(Hash) || v.is_a?(ActionController::Parameters))
      hash.delete(k) if block.call(k, v)
    end 
  end
end

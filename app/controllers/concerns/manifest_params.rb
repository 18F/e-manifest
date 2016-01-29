module ManifestParams
  def manifest_params
    parse_params
    deep_reject!(params.fetch(:manifest, {})) { |k, v| v.blank? }
  end

  private

  def parse_params
    ManifestParamParser.new(params).run
  end

  def deep_reject!(hash, &block)
    hash.each do |k, v|
      if (v.is_a?(Hash) || v.is_a?(ActionController::Parameters))
        deep_reject!(v, &block)
      elsif v.is_a?(Array)
        v.each do |item|
          if item.is_a?(Hash)
            deep_reject!(item, &block)
          end
        end
      end

      if block.call(k, v)
        hash.delete(k)
      end
    end
  end
end

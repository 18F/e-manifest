class ManifestSigner
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def perform
    output_stream = StreamLogger.new(Rails.logger)

    cdx_start = Time.current

    parsed_args = ManifestTokenJsonConverter.new(args).replace_with_json_cdx_token

    cdx_response = CDX::Manifest.new(parsed_args, output_stream).sign

    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX signature time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    if cdx_response.key?(:document_id)
      update_manifest(cdx_response, args)
    end

    cdx_response
  end

  private
  
  def update_manifest(cdx_response, args)
    manifest.document_id = cdx_response[:document_id]
    manifest.activity_id = args[:activity_id]
    manifest.signed_at = Time.current
    manifest.save!
  end

  def manifest
    @_manifest ||= args[:manifest]
  end
end

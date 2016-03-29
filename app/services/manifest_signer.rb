class ManifestSigner
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def perform
    output_stream = StreamLogger.new(Rails.logger)

    modified_args = ManifestTokenJsonConverter.new(args).replace_with_json_cdx_token

    cdx_start = Time.current

    cdx_response = CDX::Manifest.new(modified_args, output_stream).submit

    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX signature time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    if cdx_response.key?(:transaction_id)
      update_manifest(cdx_response, args)
    end

    cdx_response
  end

  def update_manifest(cdx_response, args)
    manifest.transaction_id = cdx_response[:transaction_id]
    manifest.activity_id = args[:activity_id]
    manifest.submitted_at = Time.current
    manifest.save!
  end

  private
  
  def manifest
    @_manifest ||= args[:manifest]
  end
end

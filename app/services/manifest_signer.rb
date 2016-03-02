class ManifestSigner
  def initialize(args)
    @args = args
  end

  def perform
    output_stream = StreamLogger.new(Rails.logger)

    cdx_start = Time.current

    cdx_response = CDX::Manifest.new(parsed_args, output_stream).sign

    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX signature time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    if cdx_response.key?(:document_id)
      update_manifest(cdx_response, args)
    end

    cdx_response
  end

  private

  attr_reader :args

  def update_manifest(cdx_response, args)
    manifest.document_id = cdx_response[:document_id]
    manifest.activity_id = args[:activity_id]
    manifest.signed_at = Time.current
    manifest.save!
  end

  def parsed_args
    args[:manifest] = manifest.content.to_json

    if args[:token]
      args[:token] = lookup_signature_token(args[:token])
    end

    args
  end

  def manifest
    @_manifest ||= args[:manifest]
  end

  def lookup_signature_token(user_token)
    session = UserSession.new(user_token)
    session.cdx_token
  end
end

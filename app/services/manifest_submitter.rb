class ManifestSubmitter
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def perform
    output_stream = StreamLogger.new(Rails.logger)

    cdx_start = Time.current

    cdx_response = CDX::Manifest.new(parsed_args, output_stream).submit

    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX submit time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    cdx_response
  end

  private

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

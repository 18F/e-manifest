class ManifestSigner
  def initialize(args)
    @args = args
  end

  def perform
    cdx_start = Time.current

    cdx_response = CDX::Manifest.new(parsed_args).sign

    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX signature time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    if cdx_response.key?(:document_id)
      manifest.document_id = cdx_response[:document_id]
      manifest.activity_id = args[:activity_id]
      manifest.signed_at = Time.current
      manifest.save!
    end

    cdx_response
  end

  private

  attr_reader :args

  def parsed_args
    args[:manifest] = manifest.content.to_s

    if args[:token]
      args[:token] = lookup_signature_token(args[:token])
    end

    args
  end

  def manifest
    @_manifest ||= args[:manifest]
  end

  def lookup_signature_token(user_token)
    redis = Redis.new
    redis.get(user_token)
  end
end

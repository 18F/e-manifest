class ManifestSubmitter
  include Pundit
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def perform
    output_stream = StreamLogger.new(Rails.logger)

    manifest = Manifest.find_by_uuid_or_tracking_number!(args[:manifest_id])
    authorize manifest, :can_submit?

    cdx_start = Time.current

    parsed_args = ManifestTokenJsonConverter.new(args).replace_with_json_cdx_token

    cdx_response = CDX::Manifest.new(parsed_args, output_stream).submit

    cdx_stop = Time.current
    Rails.logger.debug(ANSI.blue{ "  CDX submit time: #{sprintf('%#g', (cdx_stop - cdx_start))} seconds" })

    cdx_response
  end
end

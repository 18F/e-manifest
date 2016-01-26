module CdxHelper
  def output_stream
    @output_stream ||= StringIO.new('')
  end

  def stream_logger
    @stream_logger ||= StreamLogger.new(Rails.logger)
  end
end

module CdxHelper
  def output_stream
    @output_stream ||= StringIO.new('')
  end
end

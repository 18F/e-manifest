class CDX::Manifest
  attr_reader :opts, :output_stream

  def initialize(opts, output_stream=$stdout)
    @opts = opts
    @output_stream = output_stream
  end

  def sign
    validate_answer
    repackage_response
  rescue Exception => error
    CDX::HandleError.new(error, output_stream).perform
  end

  private

  def repackage_response
    {
      document_id: document_id
    }
  end

  def validate_answer
    CDX::Answer.new(opts, output_stream).validate
  end

  def document_id
    @document_id ||= CDX::Sign.new(opts, output_stream).perform
  end
end

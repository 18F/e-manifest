class CDX::Manifest
  attr_reader :opts, :output_stream

  def initialize(opts, output_stream=$stdout)
    @opts = opts
    @output_stream = output_stream
  end

  def submit
    validate_answer
    repackage_response
  rescue Savon::SOAPFault => error
    log_and_repackage_error(error)
  end

  private

  def validate_answer
    @_answer ||= CDX::Answer.new(opts, output_stream).perform
  end

  def repackage_response
    if validate_answer == true
      { transaction_id: transaction_id }
    else
      validate_answer
    end
  end

  def transaction_id
    @transaction_id ||= CDX::Sign.new(opts, output_stream).perform
  end

  def log_and_repackage_error(error)
    CDX::HandleError.new(error, output_stream).perform
  end
end

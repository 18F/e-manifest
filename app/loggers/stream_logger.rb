class StreamLogger
  def initialize(rails_logger)
    @rails_logger = rails_logger
  end

  def puts(string)
    @rails_logger.debug(string)
  end
end

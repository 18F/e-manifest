class CDX::LoggedRequest
  attr_reader :opts, :output_stream

  def initialize(opts, output_stream=$stdout)
    @opts = opts
    @output_stream = output_stream
  end

  def perform
    log_opts
    log_response
    repackage_response
  end

  private

  def log_opts
    output_stream.puts self.class.name
    output_stream.puts opts
  end

  def log_response
    output_stream.puts "---"
    output_stream.puts response.body
    output_stream.puts "---"
  end

  def response
    @respose ||= request
  end

  def client
    @client ||= CDX::Client::Signin
  end

  def request
    raise NotImplementedError
  end

  def repackage_response
    raise NotImplementedError
  end
end

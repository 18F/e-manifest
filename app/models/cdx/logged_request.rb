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
    if log?
      output_stream.puts ANSI.blue{ self.class.name }
      output_stream.puts ANSI.blue{ opts.pretty_inspect }
    end
  end

  def log_response
    if log?
      output_stream.puts ANSI.green{ response.body.pretty_inspect }
    end
  end

  def response
    @response ||= request
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

  def log?
    client.savon.globals[:log]
  end
end

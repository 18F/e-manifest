class CDX::System < CDX::LoggedRequest
  attr_reader :output_stream

  def initialize(output_stream=$stdout)
    @output_stream = output_stream
  end

  alias :authenticate :perform

  private

  def log_opts
    # no-op
  end

  def log_response
    output_stream.puts(client.operations)
    super
  end

  def repackage_response
    response.body[:authenticate_response][:security_token]
  end

  def response
    @response ||= client.call(
      :authenticate,
      { message: credentials }
    )
  end

  def credentials
    {
      userId: ENV['CDX_USERNAME'],
      credential: ENV['CDX_PASSWORD'],
      domain: 'default',
      authenticationMethod: 'password'
    }
  end
end

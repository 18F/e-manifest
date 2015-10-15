module CDX
  class System < LoggedRequest
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
      output_stream.puts client.operations
      super
    end

    def response
      @response ||= client.call(:authenticate, {
        message: {
          :userId => $cdx_username, :credential => $cdx_password,
          :domain => "default", :authenticationMethod => "password"
        }
      })
    end

    def repackage_response
      response.body[:authenticate_response][:security_token]
    end
  end
end

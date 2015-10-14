module CDX
  class System
    attr_reader :output_stream

    def initialize(output_stream=$stdout)
      @output_stream = output_stream
    end

    def authenticate
      puts client.operations
      puts "---"
      puts response.body
      puts "---"
      token
    end

    private

    def response
      @response ||= client.call(:authenticate, {
        message: {
          :userId => $cdx_username, :credential => $cdx_password,
          :domain => "default", :authenticationMethod => "password"
        }
      })
    end

    def client
      CDX::Client::Signin
    end

    def token
      response.body[:authenticate_response][:security_token]
    end

    extend Forwardable

    def_delegators :output_stream, :puts
  end
end

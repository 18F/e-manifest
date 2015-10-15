module CDX
  class Activity
    attr_reader :opts, :output_stream

    def initialize(opts, output_stream=$stdout)
      @opts = opts
      @output_stream = output_stream
    end

    def create
      log_response
      activity_id
    end

    private

    def log_response
      output_stream.puts "---"
      output_stream.puts response.body
      output_stream.puts "---"
    end

    def request_properties
      [
        {:Property => {:Key => "activityDescription", :Value => opts[:activity_description]}},
        {:Property => {:Key => "roleCode", :Value => opts[:role_code]}}
      ]
    end

    def response
      @response ||= client.call(:create_activity_with_properties, {
        message: {
          :securityToken => opts[:token],
          :signatureUser => opts[:signature_user],
          :dataflowName => opts[:dataflow_name],
          :properties => request_properties
        }
      })
    end

    def activity_id
      response.body[:create_activity_with_properties_response][:activity_id]
    end

    def client
      @client ||= CDX::Client::Signin
    end
  end
end

module CDX
  class Authenticator
    attr_reader :opts, :output_stream

    def initialize(opts, output_stream=$stdout)
      @opts = opts
      @output_stream = output_stream
    end

    def perform
      repackage_response
    rescue Savon::SOAPFault => e
      log_and_repackage_error(e)
    end

    private

    def signature_user
      @signature_user ||= CDX::User.new(opts, output_stream).authenticate
    end

    def security_token
      @security_token ||= CDX::System.new(output_stream).authenticate
    end

    def activity_id
      @activity_id ||= CDX::Activity.new({
        :token => security_token,
        :signature_user => signature_user,
        :dataflow_name => "eManifest",
        :activity_description => "development test",
        :role_name => "TSDF",
        :role_code => 112090
      }, output_stream).create
    end

    def question
      @question ||= CDX::Question.new({
        token: security_token,
        activity_id: activity_id,
        user: signature_user
      }, output_stream).get
    end

    def repackage_response
      {
        :token => security_token,
        :activityId => activity_id,
        :question => question,
        :userId => signature_user[:UserId]
      }
    end

    def log_and_repackage_error(error)
      output_stream.puts error.to_hash
      fault_detail = error.to_hash[:fault][:detail]
      if (fault_detail.key?(:register_auth_fault))
        description = fault_detail[:register_auth_fault][:description]
      else
        description = fault_detail[:register_fault][:description]
      end
      output_stream.puts description
       {:description => description}
    end
  end
end

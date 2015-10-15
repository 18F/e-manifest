module CDX
  class Answer
    attr_reader :opts, :output_stream

    def initialize(opts, output_stream=$stdout)
      @opts = opts
      @output_stream = output_stream
    end

    def validate
      log_response
      repackage_response
    end

    private

    def response
      @response ||= CDX::Client::Signin.call(:validate_answer, {
        message: {
          :securityToken => opts["token"],
          :activityId => opts["activityId"],
          :userId => opts["userId"],
          :questionId => opts["questionId"],
          :answer => opts["answer"]
        }
      })
    end

    def log_response
      output_stream.puts "---"
      output_stream.puts response.body
      output_stream.puts "---"
    end

    def repackage_response
      response.body[:validate_answer_response][:valid_answer]
    end
  end
end

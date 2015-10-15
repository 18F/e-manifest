module CDX
  class Question
    attr_reader :opts, :output_stream

    def initialize(opts, output_stream=$stdout)
      @opts = opts
      @output_stream = output_stream
    end

    def get
      log_response
      repackage_data
    end

    private

    def log_response
      output_stream.puts "---"
      output_stream.puts response.body
      output_stream.puts "---"
    end

    def response
      @response ||= CDX::Client::Signin.call(:get_question, {
        message: {
          :securityToken => opts[:token],
          :activityId =>    opts[:activity_id],
          :userId =>        opts[:user][:UserId]
        }
      })
    end

    def question_response_data
      response.body[:get_question_response][:question]
    end

    def repackage_data
      {
        :questionId => question_response_data[:question_id],
        :questionText => question_response_data[:text]
      }
    end
  end
end


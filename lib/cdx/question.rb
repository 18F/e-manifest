module CDX
  class Question < LoggedRequest
    alias :get :perform

    private

    def request
      client.call(:get_question, {
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

    def repackage_response
      {
        :questionId => question_response_data[:question_id],
        :questionText => question_response_data[:text]
      }
    end
  end
end


class CDX::Question < CDX::LoggedRequest
  private

  def request
    client.call(
      :get_question,
      {
        message: {
          securityToken: opts[:token],
          activityId: opts[:activity_id],
          userId: opts[:user][:UserId]
        }
      }
    )
  end

  def question_response_data
    response.body[:get_question_response][:question]
  end

  def repackage_response
    {
      question_id: question_response_data[:question_id],
      question_text: question_response_data[:text]
    }
  end
end

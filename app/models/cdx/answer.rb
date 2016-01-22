class CDX::Answer < CDX::LoggedRequest
  def perform
    super
  rescue Savon::SOAPFault => error
    log_and_repackage_error(error)
  end

  private

  def request
    client.call(
      :validate_answer,
      {
        message: {
          securityToken: opts[:token],
          activityId: opts[:activity_id],
          userId: opts[:user_id],
          questionId: opts[:question_id],
          answer: opts[:answer]
        }
      }
    )
  end

  def repackage_response
    validate_answer_response = response.body[:validate_answer_response]
    if validate_answer_response
      validate_answer_response[:valid_answer]
    end
  end

  def log_and_repackage_error(error)
    CDX::HandleError.new(error, output_stream).perform
  end
end

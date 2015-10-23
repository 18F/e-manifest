module CDX
  class Answer < LoggedRequest
    alias :validate :perform

    private

    def request
      client.call(:validate_answer, {
        message: {
          :securityToken => opts["token"],
          :activityId => opts["activity_id"],
          :userId => opts["user_id"],
          :questionId => opts["question_id"],
          :answer => opts["answer"]
        }
      })
    end

    def repackage_response
      response.body[:validate_answer_response][:valid_answer]
    end
  end
end

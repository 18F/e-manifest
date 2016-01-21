require 'rails_helper'

describe 'CDX::Authenticator.new(args, output_stream).perform' do
  it 'returns the repackaged data' do
    VCR.use_cassette('create_authenticator') do
      question = {
        question_id: "1",
        question_text: "What is the first and middle name of your oldest sibling?"
      }
      security_token_from_fixture = 'fakeSecurityToken'
      activity_id_from_fixture = 'fakeActivityId'
      user_id_from_fixture = 'fakeUserId'
      opts = { user_id: 'fakeUserId', password: 'fakePassword' }

      expect(CDX::Authenticator.new(opts, output_stream).perform).to eq({
        token: security_token_from_fixture,
        activity_id: activity_id_from_fixture,
        question: question,
        user_id: user_id_from_fixture
      })
    end
  end

  describe 'when there is an authentication error' do
    context "user id does not exist in CDX" do
      it 'returns the error description' do
       VCR.use_cassette('create_authenticator_with_wrong_user_id') do
          opts = { user_id: "wrong", password: "wrong" }

          authenticator = CDX::Authenticator.new(opts, output_stream).perform

          expect(authenticator).to eq(
            { description: 'user WRONG does not exist' }
          )
       end
      end
    end

    context "password is incorrect" do
      it 'returns the error description' do
        VCR.use_cassette('create_authenticator_with_wrong_password') do
          opts = { user_id: "real_user_id", password: "wrong" }

          authenticator = CDX::Authenticator.new(opts, output_stream).perform

          expect(authenticator).to eq(
            { description: 'Unable to authenticate user - The password is invalid.' }
          )
        end
      end
    end
  end

  describe 'when there is a register error' do
    it 'returns the error description' do
      VCR.use_cassette('create_authenticator_with_register_error') do
        opts = { user_id: "real_user_id", password: "correct_password" }

        authenticator = CDX::Authenticator.new(opts, output_stream).perform

        expect(authenticator).to eq(
          {
            description: 'Unable to authenticate user - The user account could not be located. Could not perform central authentication for user <change_me> in domain <default>'
          }
        )
      end
    end
  end

  private

  def output_stream
    @_output_stream ||= StringIO.new('')
  end
end

require 'rails_helper'

describe 'POST /api/v0/tokens' do
  it 'returns a 401 and no token when auth fails' do
    VCR.use_cassette('auth_failure') do
      user_credentials = { user_id: 'incorrect_user_id', password: 'incorrect_pw' }
      token_params = { token: user_credentials }

      post '/api/v0/tokens',
        token_params.to_json,
        set_headers

      expect(response.status).to eq(401)
      expect(parsed_response['token']).to be_nil
      expect(parsed_response['errors']).to eq(
        'Unable to authenticate user - The user account could not be located. Could not perform central authentication for user <change_me> in domain <default>'
      )
    end
  end

  it 'returns token on success' do
    VCR.use_cassette('auth_success') do
      user_credentials = { user_id: 'correct_username', password: 'correct_pw' }
      token_params = { token: user_credentials }

      post '/api/v0/tokens',
        token_params.to_json,
        set_headers

      expect(response.status).to eq(200)
      expect(parsed_response['token']).not_to be_nil
      expect(Redis.new.get(parsed_response['token'])).to_not be_nil
     end
  end

  private

  def parsed_response
    JSON.parse(response.body)
  end
end

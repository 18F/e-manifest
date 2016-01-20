require 'rails_helper'

describe 'POST /api/v0/tokens' do
  it 'returns token on success' do
    authenticator = double('authenticator', perform: { it: 'worked', token: 'server' })
    user_credentials = { user_id: 'fake_user_id', password: 'fake_pw' }
    token_params = { token: user_credentials }
    expect(CDX::Authenticator).to receive(:new)
      .with(user_credentials)
      .and_return(authenticator)

    post '/api/v0/tokens',
      token_params.to_json,
      set_headers

    session_id = request.session.id
    expect(response.status).to eq(200)
    expect(response.body).to eq({ it: 'worked', token: session_id }.to_json)
  end
end

require 'rails_helper'

describe '#CDX::User.new(args, output_stream).perform' do
  it 'should return a re-packaged response' do
    VCR.use_cassette('auth_success') do
      first_name_from_fixture = "Brandon"
      last_name_from_fixture = "Kirby"
      user_id_from_fixture = "18F_CERTIFIER"

      authenticate_user_call = CDX::User.new(user_input_data, output_stream).perform

      expect(authenticate_user_call).to eq({
        UserId: user_id_from_fixture,
        FirstName: first_name_from_fixture,
        LastName: last_name_from_fixture,
        MiddleInitial: nil,
      })
    end
  end

  it 'throws some debugging into stdout' do
    VCR.use_cassette('auth_success') do
      user = CDX::User.new(user_input_data, output_stream)

      user.perform

      expect(user.output_stream.string).to include(user_input_data.to_s)
    end
  end

  private

  def user_input_data
    { user_id: 'example_user_id', password: 'example_ps'}
  end
end

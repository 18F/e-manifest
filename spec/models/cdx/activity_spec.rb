require 'rails_helper'

describe 'CDX::Activity.new(args, output_stream).perform' do
  it 'returns the activity_id from the response' do
    VCR.use_cassette('create_activity_with_properties') do
      activity_id_from_fixture = "_e88f9df3-ce3e-45bc-91ff-6c6601d85442"

      activity = CDX::Activity.new(args, output_stream).perform

      expect(activity).to eq(activity_id_from_fixture)
    end
  end

  private

  def output_stream
    @_output_stream ||= StringIO.new('')
  end

  def args
    {
      activity_description: 'activity_description',
      role_code: 'role_code',
      token: token_from_fixture,
      signature_user: 'signature_user',
      dataflow_name: 'dataflow_name'
    }
  end

  def token_from_fixture
    "fakeSecurityToken"
  end
end

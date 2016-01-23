require 'rails_helper'

describe 'CDX::System.new(output_stream).perform' do
  it 'makes a request for operations and logs to stdout' do
    VCR.use_cassette('auth_success') do
      system = CDX::System.new(output_stream)

      system.perform

      expect(system.output_stream.string).to include("authenticate_user")
    end
  end

  it 'returns the authentication token' do
    VCR.use_cassette('auth_success') do
      security_token_from_fixture = 'fakeSecurityToken'

      system = CDX::System.new(output_stream).perform

      expect(system).to eq(security_token_from_fixture)
    end
  end
end


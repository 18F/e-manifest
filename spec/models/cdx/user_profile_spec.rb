require 'rails_helper'

describe 'CDX::UserProfile' do
  it '#perform' do
    VCR.use_cassette('user_profile_perform') do
      opts = { user_id: 'e-manifest-dev' }
      profile = CDX::UserProfile.new(opts, stream_logger).perform
      expect(profile[:firstName]).to eq('Test')
    end
  end
end

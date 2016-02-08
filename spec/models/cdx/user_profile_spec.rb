require 'rails_helper'

describe 'CDX::UserProfile' do
  it '#perform' do
    VCR.use_cassette('user_profile_perform') do
      opts = { user_id: 'e-manifest-dev' }
      profile = CDX::UserProfile.new(opts, output_stream).perform
      expect(profile[:first_name]).to eq('Test')
    end
  end

  private

  def output_stream
    @_output_stream ||= StringIO.new('')
  end
end

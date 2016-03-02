require 'rails_helper'

describe 'CDX::UserOrganizations' do
  it '#perform' do
    VCR.use_cassette('user_organizations_perform') do
      opts = { user_id: 'e-manifest-dev', dataflow: 'eManifest' }
      orgs = CDX::UserOrganizations.new(opts, stream_logger)
      response = orgs.perform
      expect(response[0][:organizationName]).to eq('EPA 2')
    end
  end
end

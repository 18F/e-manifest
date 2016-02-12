require 'rails_helper'

describe UserProfileSyncer do
  it 'builds orgs + roles from a profile' do
    user = create(:user, cdx_user_id: 'some_user')
    syncer = UserProfileSyncer.new(user, mock_cdx_user_profile)
    syncer.run
    expect(user.organizations.map(&:cdx_org_name)).to eq(['EPA 2'])
    expect(user.roles.map(&:cdx_role_name)).to eq(['TSDF'])
  end
end

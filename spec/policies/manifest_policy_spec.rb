require 'rails_helper'

describe ManifestPolicy do
  permissions :can_sign? do
    it 'allows user with signer role to sign own manifest' do
      user = create(:user)
      manifest = create(:manifest, user: user)
      profile_syncer = UserProfileSyncer.new(user, mock_cdx_user_profile)
      profile_syncer.run

      expect(ManifestPolicy).to permit(user, manifest)
    end

    it 'disallows user with signer role to sign manifest owned by someone in different org' do
      user = create(:user)
      manifest = create(:manifest)
      profile_syncer = UserProfileSyncer.new(user, mock_cdx_user_profile)
      profile_syncer.run

      expect(ManifestPolicy).to_not permit(user, manifest)
    end

    it 'allows user with signer role to sign manifest owned by someone in shared org' do
      user = create(:user)
      user2 = create(:user)
      manifest = create(:manifest, user: user2)
      profile_syncer = UserProfileSyncer.new(user, mock_cdx_user_profile)
      profile_syncer.run
      profile_syncer2 = UserProfileSyncer.new(user2, mock_cdx_user_profile)
      profile_syncer2.run

      expect(ManifestPolicy).to permit(user, manifest)
    end

    it 'disallows user with signer role in different org from the org shared with manifest owner' do
      user = create(:user)
      user2 = create(:user)
      manifest = create(:manifest, user: user2)
      org1 = create(:organization)
      org2 = create(:organization)
      signer_role = create(:role, :tsdf_certifier)
      anon_role = create(:role)
      uor1 = create(:user_org_role, user: user, organization: org1, role: signer_role)
      uor2 = create(:user_org_role, user: user, organization: org2, role: anon_role)
      uor3 = create(:user_org_role, user: user2, organization: org2, role: signer_role)

      expect(ManifestPolicy).to_not permit(user, manifest)
    end

    it 'disallows signer with non-active signer role' do
      user = create(:user)
      manifest = create(:manifest, user: user)
      profile = mock_cdx_user_profile
      profile[:organizations]['EPA 2'][:roles]['TSDF Certifier'][:status][:code] = 'Awaiting Approval'
      profile[:organizations]['EPA 2'][:roles]['TSDF Certifier'][:status][:description] = 'Awaiting Approval'
      profile_syncer = UserProfileSyncer.new(user, profile)
      profile_syncer.run

      expect(ManifestPolicy).to_not permit(user, manifest)
    end
  end
end

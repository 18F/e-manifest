require 'rails_helper'

describe User do
  describe 'Associations' do
    it { should have_many(:manifests) }
    it { should have_many(:user_org_roles) }
    it { should have_many(:roles) }
    it { should have_many(:organizations) }
  end

  describe 'cdx_user_id' do
    it 'is always required' do
      user = create(:user)
      expect(user.cdx_user_id).to_not be_nil    
    end

    it 'is unique' do
      user = create(:user)
      expect {
        create(:user, cdx_user_id: user.cdx_user_id)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it '#find_or_create' do
      user = User.find_or_create(SecureRandom.hex()[0..15])
      user2 = User.find_or_create(user.cdx_user_id)
      expect(user).to eq user2
    end
  end

  describe 'user_org_roles' do
    it '#role_for_org' do
      user_org_role = create(:user_org_role)
      user = user_org_role.user
      organization = user_org_role.organization
      role = user_org_role.role
      expect(user.role_for_org(organization.cdx_org_name, role.cdx_role_name)).to eq([user_org_role])
    end

    it '#has_role_for_org?' do
      user_org_role = create(:user_org_role)
      user = user_org_role.user
      organization = user_org_role.organization
      role = user_org_role.role
      expect(user.has_role_for_org?(organization.cdx_org_name, role.cdx_role_name)).to eq(true)
    end

    it '#org_role_status_for' do
      user_org_role = create(:user_org_role, cdx_status: 'foo')
      user = user_org_role.user
      organization = user_org_role.organization
      role = user_org_role.role
      expect(user.org_role_status_for(organization.cdx_org_name, role.cdx_role_name)).to eq('foo')
    end

    it '#shares_organization?' do
      user_org_role1 = create(:user_org_role)
      user1 = user_org_role1.user
      user_org_role2 = create(:user_org_role, organization: user_org_role1.organization)
      user2 = user_org_role2.user
      user_org_role3 = create(:user_org_role)
      user3 = user_org_role3.user

      expect(user1.shares_organization?(user2)).to eq true
      expect(user1.shares_organization?(user3)).to eq false
    end

    it '#shares_organizations' do
      user_org_role1 = create(:user_org_role)
      user1 = user_org_role1.user
      user_org_role2 = create(:user_org_role, organization: user_org_role1.organization)
      user2 = user_org_role2.user
      user_org_role3 = create(:user_org_role)
      user3 = user_org_role3.user

      expect(user1.shares_organizations(user2)).to eq([user_org_role1.organization_id])
      expect(user1.shares_organizations(user3)).to eq([])
    end

    it '#tsdf_certifier?' do
      user_org_role = create(:user_org_role, :tsdf_certifier)

      expect(user_org_role.user.tsdf_certifier?).to eq true
    end

    it '#state_data_downloader?' do
      user_org_role = create(:user_org_role, :state_data_download)

      expect(user_org_role.user.state_data_downloader?).to eq true
    end

    it '#epa_data_downloader?' do
      user_org_role = create(:user_org_role, :epa_data_download)

      expect(user_org_role.user.epa_data_downloader?).to eq true
    end
  end
end

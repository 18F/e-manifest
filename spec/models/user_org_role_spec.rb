require 'rails_helper'

describe UserOrgRole do
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
    it { should belong_to(:organization) }
  end

  describe '#state' do
    it 'parses json profile' do
      user_org_role = create(:user_org_role, profile: { subject: 'KS' })

      expect(user_org_role.state).to eq 'KS'
    end
  end

  describe '#subject' do
    it 'parses json profile' do
      user_org_role = create(:user_org_role, profile: { subject: 'KS' })

      expect(user_org_role.subject).to eq 'KS'
    end
  end
end

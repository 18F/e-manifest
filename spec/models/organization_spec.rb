require 'rails_helper'

describe Organization do
  describe 'Associations' do
    it { should have_many(:user_org_roles) }
    it { should have_many(:users) }
    it { should have_many(:roles) }
  end

  describe '#from_cdx' do
    it 'parsed CDX response' do
      cdx_org = { organization_name: 'foo', organization_id: '123' }
      organization = Organization.from_cdx(cdx_org)
      expect(organization).to be_a(Organization)
      expect(organization.cdx_org_name).to eq('foo')
      expect(organization.cdx_org_id).to eq('123')
    end
  end
end

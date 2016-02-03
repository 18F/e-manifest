require 'rails_helper'

describe Role do
  describe 'Associations' do
    it { should have_many(:user_org_roles) }
    it { should have_many(:users) }
    it { should have_many(:organizations) }
  end 

  describe '#from_cdx' do
    it 'parsed CDX response' do
      cdx_role = { type: { code: '123', description: 'foo' } }
      role = Role.from_cdx(cdx_role)
      expect(role).to be_a(Role)
      expect(role.cdx_role_code).to eq('123')
      expect(role.cdx_role_name).to eq('foo')
    end 
  end 
end

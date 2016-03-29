require 'rails_helper'

describe Organization do
  describe 'Associations' do
    it { should have_many(:user_org_roles) }
    it { should have_many(:users) }
    it { should have_many(:roles) }
  end

  describe '#from_cdx' do
    it 'parsed CDX response' do
      cdx_org = { organizationName: 'foo', organizationId: '123' }
      organization = Organization.from_cdx(cdx_org)
      expect(organization).to be_a(Organization)
      expect(organization.cdx_org_name).to eq('foo')
      expect(organization.cdx_org_id).to eq('123')
    end
  end

  describe '#state' do
    it 'parses json profile' do
      org = build(:organization, profile: { state: {code: 'VA'} })

      expect(org.state).to eq('VA')
    end
  end

  describe '#city' do
    it 'parses json profile' do
      org = build(:organization, profile: { city: 'Foo' })

      expect(org.city).to eq 'Foo'
    end
  end

  describe '#email' do
    it 'parses json profile' do
      org = build(:organization, profile: { email: 'foo@example.com' })

      expect(org.email).to eq 'foo@example.com'
    end
  end

  describe '#zip' do
    it 'parses json profile' do
      org = build(:organization, profile: { zip: '12345' })

      expect(org.zip).to eq '12345'
    end
  end
end

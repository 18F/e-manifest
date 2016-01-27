require 'rails_helper'

describe User do
  describe 'Associations' do
    it { should have_many(:manifests) }
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
end

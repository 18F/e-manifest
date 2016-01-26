require 'rails_helper'

describe User do
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
  end
end

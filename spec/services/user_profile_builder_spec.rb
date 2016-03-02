require 'rails_helper'

describe UserProfileBuilder do
  it 'builds a profile' do
    mock_cdx_profiles
    user = create(:user, cdx_user_id: 'some_user')
    builder = UserProfileBuilder.new(user, 'foo')
    expect(builder.run).to eq(mock_cdx_user_profile)
  end
end

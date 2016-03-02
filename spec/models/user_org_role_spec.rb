require 'rails_helper'

describe UserOrgRole do
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
    it { should belong_to(:organization) }
  end
end

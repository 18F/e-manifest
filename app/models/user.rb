class User < ActiveRecord::Base
  validates :cdx_user_id, presence: true, uniqueness: true
end

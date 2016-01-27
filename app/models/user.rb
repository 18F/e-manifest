class User < ActiveRecord::Base
  validates :cdx_user_id, presence: true, uniqueness: true

  has_many :manifests

  def self.find_or_create(cdx_user_id)
    find_by(cdx_user_id: cdx_user_id) || create(cdx_user_id: cdx_user_id)
  end
end

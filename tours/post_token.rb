require_relative 'tour_helper'

class PostToken < Tourist
  include TourHelper

  def tour_post_token
    manifest = create_manifest
    token_response = authenticate_manifest(manifest)
    assert_equal(token_response.status, 200, "manifest token created OK")
  end
end

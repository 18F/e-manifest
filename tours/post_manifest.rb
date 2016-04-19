require_relative 'tour_helper'

class PostManifest < Tourist
  include TourHelper

  def tour_post_manifest
    manifest = create_manifest
    assert_equal(manifest[:status], 201)
  end
end

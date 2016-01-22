require_relative 'tour_helper'

class GetManifest < Tourist
  include TourHelper

  def tour_get_manifest
    manifest = create_manifest
    response = user_agent.get manifest[:uri]
    assert_equal(response.status, 200)
    assert_equal(response.body['content'], manifest[:content], "manifest.content matches what was POSTed")
  end
end

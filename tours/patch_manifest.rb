require_relative 'tour_helper'

class PatchManifest < Tourist
  include TourHelper

  def tour_patch_manifest
    manifest = create_manifest
    assert_equal(manifest[:status], 201)
    response = patch_manifest(manifest)
    assert_equal(response.status, 200)
  end
end

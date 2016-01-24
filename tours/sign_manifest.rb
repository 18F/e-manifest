require_relative 'tour_helper'

class SignManifest < Tourist
  include TourHelper

  def tour_sign_manifest
    manifest = create_manifest
    token_response = authenticate_manifest(manifest)
    signature_response = sign_manifest(token_response, manifest)
    assert_equal(signature_response.status, 200, "manifest signed OK")
  end
end

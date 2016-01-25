require_relative 'tour_helper'

class SearchManifest < Tourist
  include TourHelper

  def tour_search_default_page_size
    response = user_agent.get emanifest_api_url('/manifests/search?q=generator')
    assert_equal(response.status, 200, 'search returns 200')
  end
end

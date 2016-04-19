require_relative 'tour_helper'

class SearchMinManifest < Tourist
  include TourHelper

  def tour_search_min_page_size
    response = user_agent.get emanifest_api_url('/manifests/search?q=generator&size=10')
    assert_equal(response.status, 200, 'search returns 200')
  end
end

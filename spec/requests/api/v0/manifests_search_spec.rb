require 'rails_helper'
require "queryparams"

describe "search", elasticsearch: true do
  describe "/search" do
    it "searches all fields by default" do
      2.times.map { create(:manifest, :indexed) }
      search_for "company"
      expect(JSON.parse(response.body)["total"]).to eq 2
    end

    it "searches by specific field" do
      2.times.map { create(:manifest, :indexed) }
      search_for "content.generator.name:company"
      expect(JSON.parse(response.body)["total"]).to eq 2
    end

    it "searched by structured query" do
      2.times.map { create(:manifest, :indexed) }
      search_for_advanced({ "content.generator.name" => "company" })
      expect(JSON.parse(response.body)["total"]).to eq 2
    end
  end

  def search_for(query)
    es_execute_with_retries 3 do
      get "/api/v0/manifests/search?q=#{query}", nil, set_headers
    end
  end

  def search_for_advanced(query)
    es_execute_with_retries 3 do
      get "/api/v0/manifests/search?#{QueryParams.encode({ aq: query })}", nil, set_headers
    end
  end
end

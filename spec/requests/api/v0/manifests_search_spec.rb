require 'rails_helper'
require "queryparams"

describe "search", elasticsearch: true do
  before(:each) do
    Manifest.rebuild_index
  end

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
    get "/api/v0/manifests/search?q=#{query}"
  end

  def search_for_advanced(query)
    get "/api/v0/manifests/search?#{QueryParams.encode({ aq: query })}"
  end
end

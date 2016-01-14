require 'rails_helper'
require_relative '../../db/chores/populator'
require "queryparams"

describe "search", elasticsearch: true do
  describe "/search" do
    it "searches all fields by default" do
      populate_manifests(2)
      search_for "around+the+corner"
      expect(JSON.parse(response.body)["total"]).to eq 2
    end

    it "searches by specific field" do
      populate_manifests(2)
      search_for "content.generator.name:generator"
      expect(JSON.parse(response.body)["total"]).to eq 2
    end

    it "searched by structured query" do
      populate_manifests(2)
      search_for_advanced({ "content.generator.name" => "generator" })
      expect(JSON.parse(response.body)["total"]).to eq 2
    end
  end

  def populate_manifests(nrecords=10)
    populator = Populator.new(Manifest)
    populator.run(nrecords)
    # must index manually because triggers are disabled in test env
    Manifest.rebuild_index
  end

  def search_for(query)
    get "/api/v0/manifests/search?q=#{query}"
  end

  def search_for_advanced(query)
    get "/api/v0/manifests/search?#{QueryParams.encode({ aq: query })}"
  end
end

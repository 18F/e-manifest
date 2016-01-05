require_relative 'spec_helper'
require_relative 'request_spec_helper'
require_relative '../lib/chores/populator'
require "queryparams"

RSpec.describe "search" do
  describe "/search" do
    it "searches all fields by default" do
      populate_manifests
      search_for "around+the+corner"
      expect(JSON.parse(last_response.body)["total"]).to eq 10
    end

    it "searches by specific field" do
      populate_manifests
      search_for "content.generator.name:generator"
      expect(JSON.parse(last_response.body)["total"]).to eq 10
    end

    it "searched by structured query" do
      populate_manifests
      search_for_advanced({ "content.generator.name" => "generator" })
      expect(JSON.parse(last_response.body)["total"]).to eq 10
    end
  end

  def populate_manifests
    populator = Populator.new(Manifest)
    populator.run(10)
    # must index manually because triggers are disabled in test env
    Manifest.rebuild_index
  end

  def search_for(query)
    get "/api/0.1/manifest/search?q=#{query}"
  end

  def search_for_advanced(query)
    get "/api/0.1/manifest/search?#{QueryParams.encode({ aq: query })}"
  end
end

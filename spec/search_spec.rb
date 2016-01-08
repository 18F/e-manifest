require_relative 'support/es_spec_helper'
require_relative 'support/request_spec_helper'
require_relative '../lib/chores/populator'
require "queryparams"

describe "search" do
  describe "/search" do
    before(:context) do
      start_es_server
    end

    it "searches all fields by default" do
      populate_manifests(2)
      search_for "around+the+corner"
      expect(JSON.parse(last_response.body)["total"]).to eq 2
    end

    it "searches by specific field" do
      populate_manifests(2)
      search_for "content.generator.name:generator"
      expect(JSON.parse(last_response.body)["total"]).to eq 2
    end

    it "searched by structured query" do
      populate_manifests(2)
      search_for_advanced({ "content.generator.name" => "generator" })
      expect(JSON.parse(last_response.body)["total"]).to eq 2
    end

    after(:context) do
      stop_es_server
    end
  end

  def populate_manifests(nrecords=10)
    populator = Populator.new(Manifest)
    populator.run(nrecords)
    # must index manually because triggers are disabled in test env
    Manifest.rebuild_index
  end

  def search_for(query)
    get "/api/v1/manifests/search?q=#{query}"
  end

  def search_for_advanced(query)
    get "/api/v1/manifests/search?#{QueryParams.encode({ aq: query })}"
  end
end

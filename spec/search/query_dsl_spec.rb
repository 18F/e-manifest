require 'rails_helper'
require_relative '../../app/search/query_dsl'

describe Search::QueryDSL do
  it "converts params to ES DSL" do
    dsl = Search::QueryDSL.new(params: {q: 'foo', aq: { color: "green" } }, user: nil)
    expect(dsl.to_hash).to eq({
      query: {
        query_string: {
          query: "(foo) AND (color:(green))",
          default_operator: "and"
        },
      },
      size: Search::QueryDSL::MAX_RESULTS,
      from: 0
    })
  end

  it "applies public filter" do
    dsl = Search::QueryDSL.new(params: { public: true }, user: nil)
    expect(dsl.to_hash).to eq({
      filter: {
        bool: {
          must: [
            range: {
              created_at: {
                lt: 'now-90d'
              }
            }
          ]
        }
      },
      size: Search::QueryDSL::MAX_RESULTS,
      from: 0,
    })
  end

  # TODO pass with current_user and test filter
end

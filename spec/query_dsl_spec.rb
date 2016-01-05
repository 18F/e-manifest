RSpec.describe "QueryDSL" do
  it "converts params to ES DSL" do
    dsl = QueryDSL.new(params: {q: 'foo', aq: { color: "green" } }, current_user: nil)
    expect(dsl.to_hash).to eq({
      query: {
        query_string: {
          query: "(foo) AND (color:(green))",
          default_operator: "and"
        },
      },
      size: 20,
      from: 0
    })
  end

  # TODO pass with current_user and test filter
end

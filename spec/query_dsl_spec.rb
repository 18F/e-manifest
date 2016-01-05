RSpec.describe "QueryDSL" do
  it "converts params to ES DSL" do
    dsl = QueryDSL.new(params: {q: 'foo'}, current_user: nil)
    expect(dsl.to_hash).to eq({
      query: {
        query_string: {
          query: "foo",
          default_operator: "and"
        },
      },
      size: 20,
      from: 0
    })
  end

  # TODO pass with current_user and test filter
end

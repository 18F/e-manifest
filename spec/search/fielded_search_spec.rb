describe Search::FieldedQuery do
  it "#to_s" do
    fs = Search::FieldedQuery.new({
      foo: "bar"
    })
    expect(fs.to_s).to eq "foo:(bar)"
  end

  it "skips wildcard-only fields" do
    fs = Search::FieldedQuery.new({
      foo: "bar",
      color: "*"
    })
    expect(fs.to_s).to eq "foo:(bar)"
  end

  it "#present?" do
    fs = Search::FieldedQuery.new(nil)
    expect(fs.present?).to eq false
  end

  it "respects advanced value syntax" do
    fs = Search::FieldedQuery.new({
      amount: ">100"
    })
    expect(fs.to_s).to eq "amount:>100"
  end

  it "#to_h" do
    fs = Search::FieldedQuery.new({
      wild: "*",
      foo: "",
      bar: nil,
      bool: false,
      color: "green"
    })
    expect(fs.to_h).to eq( { color: "green" } )
  end

  it "#valid_for" do
    fs = Search::FieldedQuery.new({
      amount: 123
    })
    expect(fs.value_for(:amount)).to eq 123
  end

  it "#humanized" do
    fs = Search::FieldedQuery.new({
      "generator.name" => 123
    })
    expect(fs.humanized(Manifest).to_s).to eq "Generator name:(123)"
  end
end

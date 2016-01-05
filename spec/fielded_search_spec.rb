describe FieldedSearch do
  it "#to_s" do
    fs = FieldedSearch.new({
      foo: "bar"
    })
    expect(fs.to_s).to eq "foo:(bar)"
  end
  it "skips wildcard-only fields" do
    fs = FieldedSearch.new({
      foo: "bar",
      color: "*"
    })
    expect(fs.to_s).to eq "foo:(bar)"
  end
  it "#present?" do
    fs = FieldedSearch.new(nil)
    expect(fs.present?).to eq false
  end
  it "respects advanced value syntax" do
    fs = FieldedSearch.new({
      amount: ">100"
    })
    expect(fs.to_s).to eq "amount:>100"
  end
  it "#to_h" do
    fs = FieldedSearch.new({
      wild: "*",
      foo: "",
      bar: nil,
      bool: false,
      color: "green"
    })
    expect(fs.to_h).to eq( { color: "green" } )
  end
  it "#valid_for" do
    fs = FieldedSearch.new({
      amount: 123
    })
    expect(fs.value_for(:amount)).to eq 123
  end
  it "#humanized" do
    fs = FieldedSearch.new({
      "generator.name" => 123
    })
    expect(fs.humanized(Manifest).to_s).to eq "Generator name:(123)"
  end
end

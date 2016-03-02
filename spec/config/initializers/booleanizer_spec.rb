require 'rails_helper'

describe "String.to_bool" do
  it "recognizes truth-y values" do
    expect('true'.to_bool).to eq true
    expect('yes'.to_bool).to eq true
    expect('Y'.to_bool).to eq true
    expect('1'.to_bool).to eq true
  end

  it "recognizes false-y values" do
    expect('false'.to_bool).to eq false
    expect('no'.to_bool).to eq false
    expect('N'.to_bool).to eq false
    expect('0'.to_bool).to eq false
  end

  it "fails on nil values" do
    expect {
      'nil'.to_bool
    }.to raise_error ArgumentError
  end
end

describe "environment configuration" do
  it "respects .env file" do
    expect(ENV["TEST_ENV_VAR"]).to eq "123"
  end
end

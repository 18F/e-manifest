describe 'environment configuration' do
  it 'respects .env.test file' do
    expect(ENV['TEST_ENV_VAR']).to eq '123'
    expect(ENV['CDX_USERNAME']).to eq "change_me"
  end
end

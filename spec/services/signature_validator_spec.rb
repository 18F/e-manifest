require 'rails_helper'

describe SignatureValidator do
  it 'handles either JSON or string object' do
    json = {
      activity_id: '12345',
      answer: 'jane doe',
      question: 'name of a person',
      question_id: '1',
      token: 'ABX1234',
      user_id: 'user_id'
    }
    validator = SignatureValidator.new(json)
    expect(validator.run).to eq true
    validator = SignatureValidator.new(json.to_json)
    expect(validator.run).to eq true
  end

  it "returns false on invalid JSON" do
    json = { foo: 'bar' }.to_json
    validator = SignatureValidator.new(json)
    expect(validator.run).to eq false
  end

  it "populates errors on invalid JSON" do
    json = {
      activity_id: '12345',
      answer: 'jane doe',
      question: 'name of a person',
      question_id: '1',
      token: 'ABX123',
      foo: 'bar'
    }
    validator = SignatureValidator.new(json)

    validator.run

    expect(validator.errors.size).to eq 2
    expect(validator.error_messages).to match_array([
      %Q(The property '#/' contains additional properties ["foo"] outside of the schema when none are allowed in schema https://e-manifest.18f.gov/schemas/post-signature.json),
      %Q(The property '#/' did not contain a required property of 'user_id' in schema https://e-manifest.18f.gov/schemas/post-signature.json)
    ])
  end
end

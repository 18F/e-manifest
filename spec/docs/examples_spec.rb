require 'rails_helper'
include JsonSchemaSpecHelper
include ExampleJsonHelper

describe 'JSON schemas' do
  before(:all) do
    register_schemas_by_uri
  end

  context 'apply to examples' do
    it 'for get-manifest' do
      validate_example('get-manifest', 'manifest_response')
    end
    it 'for post-manifest' do
      validate_example('post-manifest', 'manifest')
    end 
  end

  def validate_example(schema_name, example_name)
    schema_file_path = schema_file(schema_name)
    example = read_example_json_file_as_json(example_name)
    errors = JSON::Validator.fully_validate(schema_file_path, example, errors_as_objects: true, strict: true, require_all: false)
    expect(errors).to eq []
  end
end

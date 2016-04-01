require 'rails_helper'
include JsonSchemaSpecHelper
include ExampleJsonHelper

describe 'JSON schemas' do
  before(:all) do
    register_schemas_by_uri
  end

  describe 'date fields' do
    it 'allows valid date time strings' do
      schema = schema_file('post-manifest')
      example = read_example_json_file_as_json('manifest')
      errors = validate_schema(schema, example)
      expect(errors).to eq [] 
    end

    it 'gives errors on invalid date time strings' do
      schema = schema_file('post-manifest')
      example = read_example_json_file_as_json('manifest')
      example['generator']['signatory']['date'] = 'bad date'
      errors = validate_schema(schema, example)
      expect(errors.size).to eq 1
      expect(errors.first[:failed_attribute]).to eq('Pattern')
    end
  end

  def validate_schema(schema, example)
    JSON::Validator.fully_validate(schema, example, errors_as_objects: true, strict: true, require_all: false)  end
end

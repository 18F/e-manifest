require 'rails_helper'

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

  def schema_file(name)
    "#{schema_directory}/#{name}.json"
  end

  def example_file(name)
    "#{Rails.root.join('app', 'views', 'examples')}/_#{name}.json"
  end

  def validate_example(schema_name, example_name)
    schema_file = schema_file(schema_name)
    example_file = example_file(example_name)
    example = JSON.parse(File.read(example_file))
    errors = JSON::Validator.fully_validate(schema_file, example, errors_as_objects: true)
    expect(errors).to eq []
  end

  def register_schemas_by_uri
    schema_files = Dir.glob("#{schema_directory}/*.json")
    schema_files.each do |schema_file|
      schema_buf = JSON.parse(File.read(schema_file))
      schema = JSON::Schema.new(schema_buf, :ignored)
      JSON::Validator.add_schema(schema)
    end
  end

  def schema_directory
    "#{Rails.public_path}/schemas"
  end    
end



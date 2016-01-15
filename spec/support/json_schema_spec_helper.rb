module JsonSchemaSpecHelper
  def schema_directory
    "#{Rails.public_path}/schemas"
  end

  def read_schema_file(name)
    JSON.parse(File.read("#{schema_directory}/#{name}.json"))
  end

  def register_schemas_by_uri
    schema_files = Dir.glob("#{schema_directory}/*.json")
    schema_files.each do |schema_file|
      schema_buf = JSON.parse(File.read(schema_file))
      schema = JSON::Schema.new(schema_buf, :ignored)
      JSON::Validator.add_schema(schema)
    end 
  end 
end

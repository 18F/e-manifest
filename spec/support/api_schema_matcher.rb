RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    begin
      schema_directory = "#{Rails.root}/app/schemas"
      schema_data = JSON.parse(File.read("#{schema_directory}/#{schema}.json"))
      parsed_schema = JsonSchema.parse!(schema_data)

      parsed_schema.expand_references!
      response_body = JSON.parse(response.body)
      parsed_schema.validate!(response_body)
    rescue JsonSchema::SchemaError, JSON::ParserError => _error
      raise Class.new(StandardError)
    end

    true
  end
end

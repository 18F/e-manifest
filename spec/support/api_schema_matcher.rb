RSpec::Matchers.define :match_response_schema do |schema|
  include JsonSchemaSpecHelper

  match do |response|
    register_schemas_by_uri
    begin
      schema_hash = read_schema_file(schema)
      response_body = JSON.parse(response.body)
      JSON::Validator.validate!(schema_hash, response_body, validate_schema: true)
    rescue JSON::Schema::ValidationError, JSON::ParserError => _error
      raise Class.new(StandardError)
    end

    true
  end
end

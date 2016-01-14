RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    begin
      schema_data = JSON.parse(File.read("#{schema_directory}/#{schema}.json"))
      parsed_schema = JsonSchema.parse!(schema_data)
      document_store = build_json_schema_document_store
      parsed_schema.expand_references!(store: document_store)
      response_body = JSON.parse(response.body)
      parsed_schema.validate!(response_body)
    rescue JsonSchema::SchemaError, JSON::ParserError => _error
      raise Class.new(StandardError)
    end

    true
  end

  def build_json_schema_document_store
    # load all the schema/*json files that do *not* contain an external $ref
    document_store = JsonSchema::DocumentStore.new
    schema_files = Dir.glob("#{schema_directory}/*.json")
    schema_files.each do |schema_file|
      schema_data = JSON.parse(File.read(schema_file))
      parsed_schema = JsonSchema.parse!(schema_data)
      begin
        parsed_schema.expand_references!
      rescue RuntimeError => err
        if err.to_s.match(/Reference resolution/)
          # skip this one
          next
        else
          # re-throw
          raise err
        end
      end
      document_store.add_schema(parsed_schema)
    end
    document_store
  end

  def schema_directory
    "#{Rails.public_path}/schemas"
  end
end

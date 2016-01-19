class ManifestValidator
  include JsonSchemaHelper

  attr_reader :content, :errors

  def initialize(content)
    if content.is_a?(String)
      @content = JSON.parse(content)
    else
      @content = content
    end
    register_schemas_by_uri
  end

  def run
    schema_file_path = schema_file('post-manifest')
    @errors = JSON::Validator.fully_validate(schema_file_path, content, errors_as_objects: true)
    !@errors.any?
  end

  def error_messages
    if errors
      errors.map{ |e| e[:message] }
    else
      []
    end
  end
end

class SubmitValidator < BaseValidator
  private

  def schema_file_path
    @_schema_file_path ||= schema_file('post-submit')
  end
end

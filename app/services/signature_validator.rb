class SignatureValidator < BaseValidator
  private

  def schema_file_path
    @_schema_file_path ||= schema_file('post-signature')
  end
end

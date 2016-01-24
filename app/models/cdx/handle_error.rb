require 'ansi'
require 'pp'

class CDX::HandleError
  attr_reader :error, :output_stream

  def initialize(error, output_stream=$stdout)
    @error = error
    @output_stream = output_stream
  end

  def perform
    log_error
    repackage_error
  end

  private

  def log_error
    output_stream.puts ANSI.red{ error_hash.pretty_inspect }
  end

  def repackage_error
    { description: description }
  end

  def error_hash
    error.to_hash
  end

  def description
    fault_detail = error_hash[:fault][:detail]
    parent = fault_detail[:register_auth_fault] || fault_detail[:register_fault]
    parent[:description]
  end
end

require 'json'
require 'forwardable'

require 'savon-multipart'
require_relative 'secret'

require_relative 'lib/cdx/client'
require_relative 'lib/cdx/logged_request'
require_relative 'lib/cdx/handle_error'
require_relative 'lib/cdx/user'
require_relative 'lib/cdx/system'
require_relative 'lib/cdx/activity'
require_relative 'lib/cdx/question'
require_relative 'lib/cdx/authenticator'
require_relative 'lib/cdx/answer'
require_relative 'lib/cdx/sign'
require_relative 'lib/cdx/manifest'

def authenticate_user(args, output_stream=$stdout)
  CDX::User.new(args, output_stream).authenticate
end

def authenticate_system(output_stream=$stdout)
  CDX::System.new(output_stream).authenticate
end

def create_activity(args, output_stream=$stdout)
  CDX::Activity.new(args, output_stream).create
end

def get_question(args, output_stream=$stdout)
  CDX::Question.new(args, output_stream).get
end

def authenticate(args, output_stream=$stdout)
  CDX::Authenticator.new(args, output_stream).perform
end

def validate_answer(args, output_stream=$stdout)
  CDX::Answer.new(args, output_stream).validate
end

def sign(args, output_stream=$stdout)
  CDX::Sign.new(args, output_stream).perform
end

def sign_manifest(args, output_stream=$stdout)
  CDX::Manifest.new(args, output_stream).sign
end

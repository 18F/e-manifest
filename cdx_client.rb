require 'json'
require 'forwardable'

require 'savon-multipart'
require_relative 'secret'

require_relative 'lib/cdx/client'
require_relative 'lib/cdx/logged_request'
require_relative 'lib/cdx/user'
require_relative 'lib/cdx/system'
require_relative 'lib/cdx/activity'
require_relative 'lib/cdx/question'
require_relative 'lib/cdx/authenticator'
require_relative 'lib/cdx/answer'

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

def sign_manifest(args)
  is_valid_answer = validate_answer(args)
  document_id = sign(args)
  sign_response = { :documentId => document_id }
rescue Savon::SOAPFault => error
  puts error.to_hash
  description = error.to_hash[:fault][:detail][:register_fault][:description] 
  puts description
  {:description => description}
end

def sign(args)
  manifest_id = args["id"]
  name = "e-manifest " + manifest_id
  
  signature_document = {
    :Name => name,
    :Format => "BIN",
    :Content => args[:manifest_content]
  }
  
  response =
    CDX::Client::Signin.call(:sign,
                                       message: {
                                         :securityToken => args["token"],
                                         :activityId => args["activityId"],
                                         :signatureDocument => signature_document
                                       })
  puts "---"
  puts response.body
  puts "---"
  document_id = response.body[:sign_response][:document_id]
rescue Savon::SOAPFault => error
  # throws on invalid answer
  raise error
end


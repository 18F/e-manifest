require 'json'
require 'savon-multipart'
require_relative 'secret'

$register_sign_service_client = Savon.client(
  :wsdl => "https://devngn.epacdxnode.net/cdx-register/services/RegisterSignService?wsdl",
  :pretty_print_xml => true,
  :log => true,
  :soap_version => 2,
  :multipart => true,
  :convert_request_keys_to => :none,
  :filters => [:password, :credential]
)

$register_auth_service_client = Savon.client(
  :wsdl => "https://devngn.epacdxnode.net/cdx-register/services/RegisterAuthService?wsdl",
  :pretty_print_xml => true,
  :log => true,
  :soap_version => 2,
  :convert_request_keys_to => :none,
  :filters => [:password]
)

def authenticate_user(args)
  puts args
  user_id = args["userId"]
  password = args["password"]

  response = $register_auth_service_client.call(:authenticate, :message => {
                                                  :userId => user_id, :password => password
                                                })
  puts response.hash
  user = response.hash[:envelope][:body][:authenticate_response][:user]

  signature_user = {
    :UserId => user[:user_id],
    :FirstName => user[:first_name],
    :LastName => user[:last_name],
    :MiddleInitial => user[:middle_initial]
  }

  token = authenticate_system
  activity_id = create_activity({:token => token, :signature_user => signature_user,
                                 :dataflow_name => "eManifest", :activity_description => "development test",
                                 :role_name => "TSDF", :role_code => 112090})
  question = get_question({:token => token, :activity_id => activity_id, :user => signature_user})
  return {:token => token, :activityId => activity_id, :question => question,
          :userId => signature_user[:UserId]}
rescue Savon::SOAPFault => error
  puts error.to_hash
  description = error.to_hash[:fault][:detail][:register_auth_fault][:description] 
  puts description
  return {:description => description}
end

def authenticate_system
  puts $register_sign_service_client.operations
  response = $register_sign_service_client.call(:authenticate,
                                                message: {
                                                  :userId => $cdx_username, :credential => $cdx_password,
                                                  :domain => "default", :authenticationMethod => "password"
                                                })
  puts "---"
  puts response.body
  puts "---"
  token = response.body[:authenticate_response][:security_token]
  return token
rescue Savon::SOAPFault => error
  raise error
end

def create_activity(args)
  properties = [{:Property => {:Key => "activityDescription", :Value => args[:activity_description]}},
                {:Property => {:Key => "roleCode", :Value => args[:role_code]}}]
  response = $register_sign_service_client.call(:create_activity_with_properties,
                                                message: {
                                                  :securityToken => args[:token],
                                                  :signatureUser => args[:signature_user],
                                                  :dataflowName => args[:dataflow_name],
                                                  :properties => properties
                                                })
  puts "---"
  puts response.body
  puts "---"
  activity_id = response.body[:create_activity_with_properties_response][:activity_id]
  return activity_id
rescue Savon::SOAPFault => error
  raise error
end

def get_question(args)
  response = $register_sign_service_client.call(:get_question,
                                                message: {
                                                  :securityToken => args[:token],
                                                  :activityId => args[:activity_id],
                                                  :userId => args[:user][:UserId]
                                                })
  puts "---"
  puts response.body
  puts "---"
  question = response.body[:get_question_response][:question]
  question_id = question[:question_id]
  question_text = question[:text]
  return {:questionId => question_id, :questionText => question_text}
rescue Savon::SOAPFault => error
  raise error
end

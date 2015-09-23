require 'json'
require 'savon'

$register_sign_service_client = Savon.client(
  :wsdl => "https://devngn.epacdxnode.net/cdx-register/services/RegisterSignService?wsdl",
  :pretty_print_xml => true,
  :log => true,
  :soap_version => 2,
  :filters => [:password]
)

$register_auth_service_client = Savon.client(
  :wsdl => "https://devngn.epacdxnode.net/cdx-register/services/RegisterAuthService?wsdl",
  :pretty_print_xml => true,
  :log => true,
  :soap_version => 2,
  :filters => [:password]
)

def authenticate_user(args)
  user_id = args["userId"]
  password = args["password"]
  puts "hello world"

  puts $register_auth_service_client.operations
  response = $register_auth_service_client.call(:authenticate, message: {
                                                  "userId": user_id, "password": password
                                                })
  puts response
rescue Savon::SOAPFault => error
  puts error.http.body
#  puts error.description
#  return JSON.generate({:description => error.description})
end

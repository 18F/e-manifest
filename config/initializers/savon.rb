default_opts = {
  :wsdl => "https://devngn.epacdxnode.net/cdx-register/services/RegisterSignService?wsdl",
  :pretty_print_xml => true,
  :log => true,
  :soap_version => 2,
  :convert_request_keys_to => :none,
}

Savon.client(default_opts)

class CDX::Client
  attr_reader :savon

  CDX_BASE_URL = ENV['CDX_BASE_URL'] || "https://devngn.epacdxnode.net/cdx-register/services"
  CDX_SIGN_SERVICE_URL = ENV['CDX_SIGN_SERVICE_URL'] || "#{CDX_BASE_URL}/RegisterSignService?wsdl"
  CDX_AUTH_SERVICE_URL = ENV['CDX_AUTH_SERVICE_URL'] || "#{CDX_BASE_URL}/RegisterAuthService?wsdl"
  CDX_AUTHZ_SERVICE_URL = ENV['CDX_AUTHZ_SERVICE_URL'] || "#{CDX_BASE_URL}/RegisterService?wsdl"

  def initialize(opts={})
    @savon = Savon.client(default_opts.merge(opts))
  end

  def default_opts
    {
      wsdl: CDX_SIGN_SERVICE_URL,
      pretty_print_xml: true,
      log: (ENV['CDX_LOG'].present? ? ENV['CDX_LOG'].to_bool : false),
      soap_version: 2,
      convert_request_keys_to: :none
    }
  end

  def self.signin
    new(
      {
        multipart: true,
        filters: [:password, :credential, :answer]
      }
    )
  end

  def self.auth
    new({
      filters: [:password],
      wsdl: CDX_AUTH_SERVICE_URL
    })
  end

  def self.authz
    new({
      filters: [:password],
      wsdl: CDX_AUTHZ_SERVICE_URL
    })
  end

  extend Forwardable

  def_delegators :savon, :call, :operations

  Signin = signin
  Auth = auth
  Authz = authz
end

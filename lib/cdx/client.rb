module CDX
  class Client
    attr_reader :savon

    def initialize(opts={})
      @savon = Savon.client(default_opts.merge(opts))
    end

    def default_opts
      {
        :wsdl => "https://devngn.epacdxnode.net/cdx-register/services/RegisterAuthService?wsdl",
        :pretty_print_xml => true,
        :log => true,
        :soap_version => 2,
        :convert_request_keys_to => :none,
      }
    end

    def self.signing
      new({
        :multipart => true,
        :filters => [:password, :credential, :answer]
      })
    end

    def self.auth
      new({
        :filters => [:password]
      })
    end

    extend Forwardable

    def_delegators :savon, :call

    Signing = signing
    Auth = auth
  end
end

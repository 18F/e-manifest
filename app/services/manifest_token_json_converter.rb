class ManifestTokenJsonConverter
  attr_reader :args
  
  def initialize(args)
    @args = args.clone
  end

  def replace_with_json_cdx_token
    args[:manifest] = args[:manifest].content.to_json

    if args[:token]
      args[:token] = lookup_signature_token(args[:token])
    end

    args
  end

  def lookup_signature_token(user_token)
    session = UserSession.new(user_token)
    session.cdx_token
  end
end

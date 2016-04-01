class ManifestTokenJsonConverter
  attr_reader :args
  
  def initialize(args)
    @args = args.clone
  end

  def replace_with_json_cdx_token
    args[:token] = get_cdx_token
    args[:manifest] = get_cdx_manifest_json
    args
  end

  private

  def get_cdx_token
    if args[:token]
      session = lookup_session(args[:token])
      return session.cdx_token
    end
  end

  def get_cdx_manifest_json
    if args[:token]
      session = lookup_session(args[:token])

      cromerr_signature = {
        "first_name" => args[:user_session].first_name,
        "last_name" => args[:user_session].last_name,
        "cdx_user_role_id" => args[:cdx_user_role_id],
        "cdx_user_id" => args[:current_user].cdx_user_id.upcase
      }
      
      args[:manifest].content[:cromerr_signature] = cromerr_signature
    end

    json_manifest = args[:manifest].content.to_json

    Rails.logger.debug(ANSI.blue{ "  CDX manifest: #{json_manifest}" })
    json_manifest
  end

  def lookup_session(user_token)
    session = UserSession.new(user_token)
  end

end

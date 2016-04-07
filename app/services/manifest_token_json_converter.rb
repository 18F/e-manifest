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
      cdx_user_id = args[:current_user].cdx_user_id
      cdx_user = CDX::UserProfile.new(user_id: cdx_user_id).perform

      cromerr_signature = {
        "first_name" => cdx_user[:firstName],
        "last_name" => cdx_user[:lastName],
        "cdx_user_role_id" => args[:cdx_user_role_id],
        "cdx_user_id" => cdx_user_id.upcase
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

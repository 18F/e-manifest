class CDX::ProfileRequest < CDX::LoggedRequest
  def security_token
    @security_token ||= opts[:security_token] || CDX::System.new(output_stream).perform
  end

  def user_profile
    @user_profile ||= opts[:user] || perform_user_profile
  end

  private

  def perform_user_profile
    CDX::UserProfile.new(opts.merge(security_token: security_token), output_stream).perform
  end

  def client
    CDX::Client::Authz
  end

  def lower_camelize(thing)
    if thing.is_a?(Hash)
      lower_camelize_hash(thing)
    elsif thing.is_a?(Array)
      thing.each do |subthing|
        lower_camelize(subthing)
      end
    else
      fail "Unsupported object: #{thing.pretty_inspect}"
    end
    thing
  end

  def lower_camelize_hash(hash)
    hash.keys.each do |key|
      new_key = key.to_s.camelize(:lower).to_sym
      hash[new_key] = hash.delete(key)
      if hash[new_key].is_a?(Hash) || hash[new_key].is_a?(Array)
        lower_camelize(hash[new_key])
      end
    end
  end
end

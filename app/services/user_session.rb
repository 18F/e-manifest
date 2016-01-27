class UserSession
  attr_reader :session, :token

  TTL = 4 * 60 * 60

  @@namespace = "user_session"

  def self.namespace=namespace
    @@namespace = namespace
  end

  def self.redis
    @@redis ||= Redis::Namespace.new(@@namespace.to_sym, redis: Redis.new)
  end

  def self.create(user, cdx_auth_response = nil)
    session = self.new(SecureRandom.uuid, user)
    session.set(cdx_auth_response: cdx_auth_response)
    session
  end

  def self.flush_all
    redis.scan_each do |key|
      redis.del(key)
    end
  end
 
  def initialize(token, user = nil)
    @token = token
    @user = user
    @session = find_or_create_session
  end

  def user
    if @user
      @user
    elsif get(:id)
      User.find( get(:id) )
    end
  end

  def cdx_token
    (cdx_auth_response || {})[:token]
  end

  def cdx_auth_response
    get_attr(:cdx_auth_response)
  end

  def cdx_roles

  end

  def set(attrs)
    @session.merge!(attrs)
    write_session
  end

  def get(attr_name)
    get_attr(attr_name)
  end

  def touch
    set(updated_at: Time.current)
  end

  def expire
    redis.expire(@token, -1)
  end

  def created_at
    Time.parse(get(:created_at).to_s)
  end

  def updated_at
    Time.parse(get(:updated_at).to_s)
  end

  private

  def redis
    self.class.redis
  end

  def get_attr(key)
    @session[key]
  end

  def find_or_create_session
    find_session || create_session
  end

  def find_session
    payload = redis.get(@token)
    if payload
      JSON.parse(payload, symbolize_names: true)
    end
  end

  def write_session
    @session[:updated_at] = Time.current
    redis.set(@token, @session.to_json)
    redis.expire(@token, TTL)
  end

  def create_session
    @session ||= create_payload
    write_session
    @session
  end

  def create_payload
    payload = { created_at: Time.current, updated_at: Time.current }
    if @user
      payload[:id] = @user.id  
    end
    payload
  end
end

class UserSession
  attr_reader :session, :token

  TTL = 4 * 60 * 60
  @@ttl = TTL

  @@namespace = "user_session"

  def self.namespace=namespace
    @@namespace = namespace
  end

  def self.ttl=seconds
    @@ttl = seconds.to_i
  end

  def self.redis
    @@redis ||= Redis::Namespace.new(@@namespace.to_sym, redis: Redis.new)
  end

  def self.create(user, cdx_response = nil)
    session = self.new(SecureRandom.uuid, user)
    if cdx_response && cdx_response[:description]
      cdx_response[:last_error] = cdx_response.delete(:description)
    end
    session.set(cdx: cdx_response)
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

  def user=user
    @user = user
  end

  def user_name
    if cdx[:FirstName] && cdx[:LastName]
      "#{cdx[:FirstName]} #{cdx[:LastName]}"
    else
      user.cdx_user_id
    end
  end

  def first_name
    if cdx[:FirstName]
      cdx[:FirstName]
    else
      ""
    end
  end
    
  def last_name
    if cdx[:LastName]
      cdx[:LastName]
    else
      ""
    end
  end
    
  def cdx_token
    cdx[:token]
  end

  def cdx
    get_attr(:cdx) || {}
  end

  def cdx_roles

  end

  def set(attrs)
    @session.merge!(attrs)
    write_session
    self
  end

  def get(attr_name)
    get_attr(attr_name)
  end

  def merge_cdx(more_cdx)
    if more_cdx[:description]
      more_cdx[:last_error] = more_cdx.delete(:description)
    end
    @session[:cdx] = cdx.merge(more_cdx)
    write_session
    self
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

  def signature_response
    if cdx[:token]
      {
        token: @token,
        activity_id: cdx[:activity_id],
        question: cdx[:question],
        user_id: cdx[:user_id]
      }
    else
      { description: cdx[:last_error] }
    end
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
    if @user
      @session[:id] = @user.id  
    end
    redis.set(@token, @session.to_json)
    redis.expire(@token, @@ttl)
  end

  def create_session
    @session ||= create_payload
    write_session
    @session
  end

  def create_payload
    payload = { created_at: Time.current, updated_at: Time.current }
    payload
  end
end

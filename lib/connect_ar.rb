class ConnectAR
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def connect
    return false unless url
    ActiveRecord::Base.establish_connection(
     :adapter  => parsed_url.scheme == 'postgres' ? 'postgresql' : parsed_url.scheme,
     :host     => parsed_url.host,
     :username => parsed_url.user,
     :password => parsed_url.password,
     :database => parsed_url.path[1..-1],
     :encoding => 'utf8'
    )
  end

  def parsed_url
    @parsed_url ||= URI.parse(url)
  end
end

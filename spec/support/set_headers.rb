module SetHeaders
  def set_headers(options = {})
    {
      'Content-type' => 'application/json'
    }.merge(options)
  end

  def set_request_headers(options = {})
    request.headers.merge!(set_headers(options))
  end
end

RSpec.configure do |config|
  config.include SetHeaders
end

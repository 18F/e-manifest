module SetHeaders
  def set_headers(options = {})
    {
      'Content-type' => 'application/json'
    }.merge(options)
  end
end

RSpec.configure do |config|
  config.include SetHeaders
end

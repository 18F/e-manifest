require 'faraday'
require 'faraday_middleware'
require 'pp'

module TourHelper
  def emanifest_host
    ENV['EMANIFEST_HOST'] || 'http://localhost:3000'
  end

  def emanifest_api_version
    ENV['EMANIFEST_API_VERSION'] || 'v0'
  end

  def emanifest_api_url(path)
    "#{emanifest_host}/api/#{emanifest_api_version}#{path}"
  end

  def create_manifest
    manifest_content = example_manifest_json
    response = user_agent.post do |req|
      req.url emanifest_api_url("/manifests")
      req.headers['Content-Type'] = 'application/json'
      req.body = { manifest: manifest_content }.to_json
    end
    if response.status == 201
      uri = response.body['location']
      tracking_number = response.body['message'].match(/Manifest (\w+) /)[1]
      { 
        status: response.status,
        uri: uri, 
        content: manifest_content, 
        uuid: uri.gsub(/^.+\//, ''), 
        tracking_number: tracking_number 
      }
    else
      {
        status: response.status,
        body: response.body
      }
    end
  end

  def patch_manifest(manifest)
    user_agent.patch do |req|
      req.url manifest[:uri]
      req.headers['Content-Type'] = 'application/json-patch+json'
      req.body = example_patch_manifest_json.to_json
    end
  end

  def example_manifest_json
    manifest_content = JSON.parse(File.read('app/views/examples/_manifest.json'))
    manifest_content['generator']['manifest_tracking_number'] = random_tracking_number
    manifest_content
  end

  def example_patch_manifest_json
    JSON.parse(File.read('app/views/examples/_manifest_patch.json'))
  end

  def random_tracking_number
    num = '%09d' % SecureRandom.random_number(1_000_000_000)
    str = (0...3).map { (65 + rand(26)).chr }.join
    "#{num}#{str}"
  end

  def user_agent
    Faraday.new() do |faraday|
      faraday.request(:url_encoded)
      faraday.response(:json)
      faraday.adapter(:excon)
    end
  end
end

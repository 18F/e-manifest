require 'faraday'
require 'faraday_middleware'
require 'pp'
require 'yaml'

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
      req.body = manifest_content.to_json
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

  def authenticate_manifest(manifest)
    credentials = get_random_cdx_user
    token_request = { token: credentials }
    user_agent.post do |req|
      req.url emanifest_api_url("/tokens")
      req.headers['Content-Type'] = 'application/json'
      req.body = token_request.to_json
    end
  end

  def sign_manifest(token_response, manifest)
    uri = manifest[:uri] + '/signature'
    sign_request = {
      token: token_response.body['token'],
      activity_id: token_response.body['activity_id'],
      id: manifest[:uuid],
      question_id: token_response.body['question']['question_id'],
      answer: lookup_cdx_answer(token_response.body['question']['question_text']),
      user_id: token_response.body['user_id'],
    }
    user_agent.post do |req|
      req.url uri
      req.headers['Content-Type'] = 'application/json'
      req.body = sign_request.to_json
    end
  end

  def lookup_cdx_answer(question)
    cdx_config = read_cdx_config
    answer = ''
    cdx_config['q_and_a'].each do |set|
      if set['question'] == question
        answer = set['answer']
        break
      end
    end
    answer
  end

  def get_random_cdx_user
    cdx_config = read_cdx_config
    users = cdx_config['users']
    users.shuffle.first
  end

  def read_cdx_config
    YAML.load_file('test_cdx_config.yml')
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
    Faraday.new({ headers: { 'Accept' => 'application/json' } }) do |faraday|
      faraday.request(:url_encoded)
      faraday.response(:json)
      faraday.adapter(:excon)
    end
  end
end

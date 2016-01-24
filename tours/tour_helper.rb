require 'faraday'
require 'faraday_middleware'
require 'pp'
require 'yaml'
require_relative '../app/helpers/example_json_helper'

module TourHelper
  include ExampleJsonHelper

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
    response = post_json(emanifest_api_url("/manifests"), manifest_content.to_json)
    if response.status == 201
      uri = response.body['location']
      tracking_number = response.body['message'].match(/Manifest (\w+) /)[1]
      { status: response.status, uri: uri, content: manifest_content, uuid: uri.gsub(/^.+\//, ''), tracking_number: tracking_number }
    else
      { status: response.status, body: response.body }
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
    post_json(emanifest_api_url("/tokens"), token_request.to_json)
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
    post_json(uri, sign_request.to_json)
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
    manifest_content = read_example_json_file_as_json('manifest')
    manifest_content['generator']['manifest_tracking_number'] = random_tracking_number
    manifest_content
  end

  def example_patch_manifest_json
    read_example_json_file_as_json('manifest_patch')
  end

  def post_json(uri, body)
    user_agent.post do |req|
      req.url uri
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
  end

  def get_json(uri)
    user_agent.get do |req|
      req.url uri
      req.headers['Content-Type'] = 'application/json'
    end
  end

  def user_agent
    Faraday.new({ headers: { 'Accept' => 'application/json' } }) do |faraday|
      faraday.request(:url_encoded)
      faraday.response(:json)
      faraday.adapter(:excon)
    end
  end
end

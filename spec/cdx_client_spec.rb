require 'spec_helper'

require File.dirname(__FILE__) + "/../cdx_client"

RSpec.describe 'cdx_client script' do
  describe 'clients' do
    # NOTE: this is all configuration and shouldn't really be tested ...
    # but, trying to make sure I keep the code working the same, while
    # encapsulating it a little!

    let(:signing_client) { CDX::Client.signing }
    let(:auth_client) { CDX::Client.auth }

    it 'signing client should be multipart' do
      expect(signing_client.savon.globals[:multipart]).to eq(true)
    end

    it 'signing client should have the right filters' do
      expect(signing_client.savon.globals[:filters]).to include(:password, :credential, :answer)
    end

    it 'signing client should have default keys' do
      expect(signing_client.savon.globals[:wsdl]).to_not be_nil
      expect(signing_client.savon.globals[:pretty_print_xml]).to_not be_nil
      expect(signing_client.savon.globals[:log]).to_not be_nil
      expect(signing_client.savon.globals[:soap_version]).to_not be_nil
      expect(signing_client.savon.globals[:convert_request_keys_to]).to_not be_nil
    end

    it 'auth client should have the right filters' do
      expect(auth_client.savon.globals[:filters]).to eq([:password])
    end

    it 'auth client should have default keys' do
      expect(auth_client.savon.globals[:wsdl]).to_not be_nil
      expect(auth_client.savon.globals[:pretty_print_xml]).to_not be_nil
      expect(auth_client.savon.globals[:log]).to_not be_nil
      expect(auth_client.savon.globals[:soap_version]).to_not be_nil
      expect(auth_client.savon.globals[:convert_request_keys_to]).to_not be_nil
    end
  end
end

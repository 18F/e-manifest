require 'spec_helper'

require 'stringio'

require File.dirname(__FILE__) + "/../cdx_client"

RSpec.describe 'cdx_client script' do
  describe 'available clients' do
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

  describe '#authenticate_user' do
    let(:output_stream) { StringIO.new('') }

    let(:auth_response) {
      double('respones', hash: {
        envelope: {
          body: {
            authenticate_response: {
              user: {
                user_id: 'user_id',
                first_name: 'first_name',
                last_name: 'last_name',
                middle_initial: 'middle_initial'
              }
            }
          }
        }
      })
    }

    let(:user_input_data) {
      {'userId' => 'userId', 'password' => 'password'}
    }

    let(:authenticate_user_call) {
      authenticate_user(user_input_data, output_stream)
    }

    before do
      allow(CDX::Client::Auth).to receive(:call).and_return(auth_response)
    end

    it 'should return a re-packaged response' do
      expect(authenticate_user_call).to eq({
        UserId: 'user_id',
        FirstName: 'first_name',
        LastName: 'last_name',
        MiddleInitial: 'middle_initial'
      })
    end

    it 'should call authentication with the correct stuff' do
      expect(CDX::Client::Auth).to receive(:call).with(:authenticate, {
        :message => {
          :userId => 'userId', :password => 'password'
        }
      }).and_return(auth_response)
      authenticate_user_call
    end

    it 'throws some debugging into stdout' do
      authenticate_user_call
      expect(output_stream.string).to include(user_input_data.to_s)
      expect(output_stream.string).to include(auth_response.hash.to_s)
    end
  end
end

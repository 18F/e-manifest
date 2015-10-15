require 'spec_helper'

require 'stringio'

require File.dirname(__FILE__) + "/../cdx_client"

RSpec.describe 'cdx_client script' do
  let(:output_stream) { StringIO.new('') }

  describe 'available clients' do
    # NOTE: this is all configuration and shouldn't really be tested ...
    # but, trying to make sure I keep the code working the same, while
    # encapsulating it a little!

    let(:signin_client) { CDX::Client.signin }
    let(:auth_client) { CDX::Client.auth }

    it 'signing client should be multipart' do
      expect(signin_client.savon.globals[:multipart]).to eq(true)
    end

    it 'signing client should have the right filters' do
      expect(signin_client.savon.globals[:filters]).to include(:password, :credential, :answer)
    end

    it 'signing client should have default keys' do
      expect(signin_client.savon.globals[:wsdl]).to_not be_nil
      expect(signin_client.savon.globals[:pretty_print_xml]).to_not be_nil
      expect(signin_client.savon.globals[:log]).to_not be_nil
      expect(signin_client.savon.globals[:soap_version]).to_not be_nil
      expect(signin_client.savon.globals[:convert_request_keys_to]).to_not be_nil
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

  describe '#authenticate_system' do
    let(:operations_response) { {'some' => 'operations'} }

    let(:auth_response) {
      double('response', body: {
        authenticate_response: {
          security_token: 'security_token'
        }
      })
    }

    before do
      allow(CDX::Client::Signin).to receive(:operations).and_return(operations_response)
      allow(CDX::Client::Signin).to receive(:call).and_return(auth_response)
    end

    it 'makes a request for operations and logs to stdout' do
      expect(CDX::Client::Signin).to receive(:operations).and_return(operations_response)
      authenticate_system(output_stream)
      expect(output_stream.string).to include(operations_response.to_s)
    end

    it 'makes the right authentication request via the right client' do
      expect(CDX::Client::Signin).to receive(:call).with(:authenticate, {
        message: {
          :userId => $cdx_username, :credential => $cdx_password,
          :domain => "default", :authenticationMethod => "password"
        }
      }).and_return(auth_response)
      authenticate_system(output_stream)
    end

    it 'logs the response body' do
      authenticate_system(output_stream)
      expect(output_stream.string).to include(auth_response.body.to_s)
    end

    it 'returns the authentication token' do
      expect(authenticate_system(output_stream)).to eq('security_token')
    end
  end

  describe '#create_activity' do
    let(:auth_response) {
      double('response', body: {
        create_activity_with_properties_response: {
          activity_id: 'activity_id'
        }
      })
    }

    let(:args) {
      {
        activity_description: 'activity_description',
        role_code: 'role_code',
        token: 'token',
        signature_user: 'signature_user',
        dataflow_name: 'dataflow_name'
      }
    }

    before do
      allow(CDX::Client::Signin).to receive(:call).and_return(auth_response)
    end

    it 'receives the right client call with the right data' do
      expect(CDX::Client::Signin).to receive(:call) { |operation, options|
        expect(operation).to eq(:create_activity_with_properties)
        expect(options[:message][:securityToken]).to eq('token')
        expect(options[:message][:signatureUser]).to eq('signature_user')
        expect(options[:message][:dataflowName]).to eq('dataflow_name')
        expect(options[:message][:properties].first[:Property][:Value]).to eq('activity_description')
        expect(options[:message][:properties].last[:Property][:Value]).to eq('role_code')
      }.and_return(auth_response)
      create_activity(args, output_stream)
    end

    it 'returns the activity_id from the response' do
      expect(create_activity(args, output_stream)).to eq('activity_id')
    end

    it 'logs the response body' do
      create_activity(args, output_stream)
      expect(output_stream.string).to include(auth_response.body.to_s)
    end
  end
end

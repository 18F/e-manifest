require 'spec_helper'

RSpec.describe CDX do
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

  describe '#CDX::User.new(args, output_stream).authenticate' do
    let(:auth_response) {
      double('response', hash: {
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
      CDX::User.new(user_input_data, output_stream).authenticate
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

  describe 'CDX::System.new(output_stream).authenticate' do
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
      CDX::System.new(output_stream).authenticate
      expect(output_stream.string).to include(operations_response.to_s)
    end

    it 'makes the right authentication request via the right client' do
      expect(CDX::Client::Signin).to receive(:call).with(:authenticate, {
        message: {
          :userId => $cdx_username, :credential => $cdx_password,
          :domain => "default", :authenticationMethod => "password"
        }
      }).and_return(auth_response)
      CDX::System.new(output_stream).authenticate
    end

    it 'logs the response body' do
      CDX::System.new(output_stream).authenticate
      expect(output_stream.string).to include(auth_response.body.to_s)
    end

    it 'returns the authentication token' do
      expect(CDX::System.new(output_stream).authenticate).to eq('security_token')
    end
  end

  describe 'CDX::Activity.new(args, output_stream).create' do
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
      CDX::Activity.new(args, output_stream).create
    end

    it 'returns the activity_id from the response' do
      expect(CDX::Activity.new(args, output_stream).create).to eq('activity_id')
    end

    it 'logs the response body' do
      CDX::Activity.new(args, output_stream).create
      expect(output_stream.string).to include(auth_response.body.to_s)
    end
  end

  describe 'CDX::Question.new(opts, output_stream).get' do
    let(:opts) {
      {
        token: 'token',
        activity_id: 'activity_id',
        user: {
          UserId: 'UserId'
        }
      }
    }

    let(:auth_response) {
      double('response', body: {
        get_question_response: {
          question: {
            question_id: 'question_id',
            text: 'text'
          }
        }
      })
    }

    before do
      allow(CDX::Client::Signin).to receive(:call).and_return(auth_response)
    end

    it 'calls makes the right requset with the right data' do
      expect(CDX::Client::Signin).to receive(:call) { |operation, options|
        expect(operation).to eq(:get_question)
        expect(options[:message][:securityToken]).to eq('token')
        expect(options[:message][:activityId]).to eq('activity_id')
        expect(options[:message][:userId]).to eq('UserId')
      }.and_return(auth_response)
      CDX::Question.new(opts, output_stream).get
    end

    it 'outputs the response body' do
      CDX::Question.new(opts, output_stream).get
      expect(output_stream.string).to include(auth_response.body.to_s)
    end

    it 'constructs a return value from the response' do
      expect(CDX::Question.new(opts, output_stream).get).to eq({
        questionId: 'question_id',
        questionText: 'text'
      })
    end
  end

  describe 'CDX::Authenticator.new(args, output_stream).perform' do
    let(:opts) {
      {'userId' => 'userId', 'password' => 'password'}
    }

    let(:user_signature) {
      {
        UserId: 'user_id',
        FirstName: 'first_name',
        LastName: 'last_name',
        MiddleInitial: 'middle_initial'
      }
    }

    let(:security_token) { 'security_token' }
    let(:activity_id) { 'activity_id' }

    let(:question) {
      {
        questionId: 'question_id',
        questionText: 'text'
      }
    }

    before do
      allow_any_instance_of(CDX::User).to receive(:authenticate).and_return(user_signature)
      allow_any_instance_of(CDX::System).to receive(:authenticate).and_return(security_token)
      allow_any_instance_of(CDX::Activity).to receive(:create).and_return(activity_id)
      allow_any_instance_of(CDX::Question).to receive(:get).and_return(question)
    end

    it 'makes the right requests' do
      expect_any_instance_of(CDX::User).to receive(:authenticate).and_return(user_signature)
      expect_any_instance_of(CDX::System).to receive(:authenticate).and_return(security_token)
      expect_any_instance_of(CDX::Activity).to receive(:create).and_return(activity_id)
      expect_any_instance_of(CDX::Question).to receive(:get).and_return(question)
      CDX::Authenticator.new(opts, output_stream).perform
    end

    it 'returns the repackaged data' do
      expect(CDX::Authenticator.new(opts, output_stream).perform).to eq({
        :token => security_token,
        :activityId => activity_id,
        :question => question,
        :userId => user_signature[:UserId]
      })
    end

    describe 'when there is an authentication error' do
      let(:error) {
        e = Savon::SOAPFault.new('something went wrong', double)
        allow(e).to receive(:to_hash).and_return({
          fault: {
            detail: {
              register_auth_fault: {
                description: 'bad credentials'
              }
            }
          }
        })
        e
      }

      it 'logs the error' do
        allow_any_instance_of(CDX::User).to receive(:authenticate).and_raise(error)
        CDX::Authenticator.new(opts, output_stream).perform
        expect(output_stream.string).to include('bad credentials')
      end

      it 'returns the error as repackaged data' do
        allow_any_instance_of(CDX::User).to receive(:authenticate).and_raise(error)
        expect(CDX::Authenticator.new(opts, output_stream).perform).to eq({description: 'bad credentials'})
      end
    end

    describe 'when there is a register error' do
      let(:error) {
        e = Savon::SOAPFault.new('something went wrong', double)
        allow(e).to receive(:to_hash).and_return({
          fault: {
            detail: {
              register_fault: {
                description: 'bad register???'
              }
            }
          }
        })
        e
      }

      it 'returns the error as repackaged data' do
        allow_any_instance_of(CDX::User).to receive(:authenticate).and_raise(error)
        expect(CDX::Authenticator.new(opts, output_stream).perform).to eq({description: 'bad register???'})
      end
    end
  end

  describe 'CDX::Answer.new(args, output_stream).validate' do
    let(:opts) {
      {
        'token' =>  'security_token',
        'activityId' => 'activity_id',
        'userId' => 'user_id',
        'questionId' => 'question_id',
        'answer' => 'answer'
      }
    }

    let(:auth_response) {
      double('response', {
        body: {
          validate_answer_response: {
            valid_answer: 'it is valid'
          }
        }
      })
    }

    before do
      allow(CDX::Client::Signin).to receive(:call).and_return(auth_response)
    end

    it 'sends the right request with the right data' do
      expect(CDX::Client::Signin).to receive(:call).with(:validate_answer, {
        message: {
          :securityToken => 'security_token',
          :activityId => 'activity_id',
          :userId => 'user_id',
          :questionId => 'question_id',
          :answer => 'answer'
        }
      })

      CDX::Answer.new(opts, output_stream).validate
    end

    it 'returns the repackaged response' do
      expect(CDX::Answer.new(opts, output_stream).validate).to eq('it is valid')
    end

    it 'logs response data' do
      CDX::Answer.new(opts, output_stream).validate
      expect(output_stream.string).to include('it is valid')
    end
  end

  describe 'CDX::Sign.new(args, output_stream).perform' do
    let(:opts) {
      {
        'id' =>  'id',
        :manifest_content => 'content',
        'token' => 'token',
        'activityId' => 'activity_id'
      }
    }

    let(:auth_response) {
      double('response', {
        body: {
          sign_response: {
            document_id: 'document_id'
          }
        }
      })
    }

    before do
      allow(CDX::Client::Signin).to receive(:call).and_return(auth_response)
    end

    it 'makes the right request with the right data' do
      expect(CDX::Client::Signin).to receive(:call).with(:sign, {
        message: {
          securityToken: 'token',
          activityId: 'activity_id',
          signatureDocument: {
            Name: 'e-manifest id',
            Format: 'BIN',
            Content: 'content'
          }
        }
      })
      CDX::Sign.new(opts, output_stream).perform
    end

    it 'returns the document id' do
      expect(CDX::Sign.new(opts, output_stream).perform).to eq('document_id')
    end

    it 'logs the response' do
      CDX::Sign.new(opts, output_stream).perform
      expect(output_stream.string).to include('document_id')
    end
  end

  describe 'CDX::Manifest.new(args, output_stream).sign' do
    let(:opts) {
      double('opts')
    }

    let(:error) {
      e = Savon::SOAPFault.new('something went wrong', double)
      allow(e).to receive(:to_hash).and_return({
        fault: {
          detail: {
            register_auth_fault: {
              description: 'bad credentials'
            }
          }
        }
      })
      e
    }

    before do
      allow_any_instance_of(CDX::Answer).to receive(:validate)
      allow_any_instance_of(CDX::Sign).to receive(:perform).and_return('document_id')
    end

    it 'validates the answer' do
      expect_any_instance_of(CDX::Answer).to receive(:validate)
      CDX::Manifest.new(opts, output_stream).sign
    end

    it 'signs the manifest' do
      expect_any_instance_of(CDX::Sign).to receive(:perform).and_return('document_id')
      CDX::Manifest.new(opts, output_stream).sign
    end

    it 'logs the error' do
      allow_any_instance_of(CDX::Answer).to receive(:validate).and_raise(error)
      expect(CDX::Manifest.new(opts, output_stream).sign).to eq({description: 'bad credentials'})
    end
  end
end

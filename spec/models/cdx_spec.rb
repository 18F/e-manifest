require 'rails_helper'

describe "CDX" do
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
      CDX::Question.new(opts, output_stream).perform
    end

    it 'outputs the response body' do
      CDX::Question.new(opts, output_stream).perform
      expect(output_stream.string).to include(auth_response.body.to_s)
    end

    it 'constructs a return value from the response' do
      expect(CDX::Question.new(opts, output_stream).perform).to eq({
        question_id: 'question_id',
        question_text: 'text'
      })
    end
  end

  describe 'CDX::Answer.new(args, output_stream).perform' do
    let(:opts) {
      {
        token:  'security_token',
        activity_id: 'activity_id',
        user_id: 'user_id',
        question_id: 'question_id',
        answer: 'answer'
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
          securityToken: 'security_token',
          activityId: 'activity_id',
          userId: 'user_id',
          questionId: 'question_id',
          answer: 'answer'
        }
      })

      CDX::Answer.new(opts, output_stream).perform
    end

    it 'returns the repackaged response' do
      expect(CDX::Answer.new(opts, output_stream).perform).to eq('it is valid')
    end

    it 'logs response data' do
      CDX::Answer.new(opts, output_stream).perform
      expect(output_stream.string).to include('it is valid')
    end
  end

  describe 'CDX::Sign.new(args, output_stream).perform' do
    let(:opts) {
      {
        id:  'id',
        manifest_content: 'content',
        token: 'token',
        activity_id: 'activity_id'
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
      allow_any_instance_of(CDX::Answer).to receive(:perform)
      allow_any_instance_of(CDX::Sign).to receive(:perform).and_return('document_id')
    end

    it 'validates the answer' do
      expect_any_instance_of(CDX::Answer).to receive(:perform)
      CDX::Manifest.new(opts, output_stream).sign
    end

    it 'signs the manifest' do
      expect_any_instance_of(CDX::Sign).to receive(:perform).and_return('document_id')
      CDX::Manifest.new(opts, output_stream).sign
    end

    it 'logs the error' do
      allow_any_instance_of(CDX::Answer).to receive(:perform).and_raise(error)
      expect(CDX::Manifest.new(opts, output_stream).sign).to eq({description: 'bad credentials'})
    end
  end
end

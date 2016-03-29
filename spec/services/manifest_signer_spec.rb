require 'rails_helper'

describe ManifestSigner do
  describe '#perform' do
    context 'success' do
      it 'hits the CDX API and returns the transaction id' do
        manifest = build(:manifest)
        args = {
          manifest: manifest,
          token: "1234ABC",
          activity_id: "activity id",
          answer: "Test",
          question_id: "question id",
          user_id: "user id"
        }

        cdx_manifest = double(submit: { transaction_id: "transaction_id" })
        allow(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        signer = ManifestSigner.new(args).perform

        expect(signer).to eq({ transaction_id: "transaction_id" })
      end

      it 'assigns the transaction id' do
        manifest = build(:manifest)
        args = {
          manifest: manifest,
          token: "1234ABC",
          activity_id: "activity id",
          answer: "Test",
          question_id: "question id",
          user_id: "user id"
        }

        cdx_manifest = double(submit: { transaction_id: "transaction_id" })
        allow(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        ManifestSigner.new(args).perform

        expect(manifest.transaction_id).to eq("transaction_id")
      end

      it 'assigns the activity id' do
        manifest = build(:manifest)
        args = {
          manifest: manifest,
          token: "1234ABC",
          activity_id: "activity id",
          answer: "Test",
          question_id: "question id",
          user_id: "user id"
        }

        cdx_manifest = double(submit: { transaction_id: "transaction_id" })
        allow(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        ManifestSigner.new(args).perform

        expect(manifest.activity_id).to eq("activity id")
      end

      it 'updates the submitted at timestamp' do
        manifest = build(:manifest)
        args = {
          manifest: manifest,
          token: "1234ABC",
          activity_id: "activity id",
          answer: "Test",
          question_id: "question id",
          user_id: "user id"
        }

        cdx_manifest = double(submit: { transaction_id: "transaction_id" })
        allow(CDX::Manifest).to receive(:new).and_return(cdx_manifest)

        ManifestSigner.new(args).perform

        expect(manifest.submitted_at).not_to be_nil
      end
    end
  end
end

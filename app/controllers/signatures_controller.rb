class SignaturesController < ApplicationController
  def new
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
    @response = params[:response]
    @question = params[:response][:question][:question_text]
  end

  def create
    response = CDX::Answer.new(secret_question_params).perform
    manifest = Manifest.find_by_uuid_or_tracking_number(params[:manifest_id])

    if response == true
      redirect_to manifest_signature_path(manifest.uuid)
    end
  end

  def show
    manifest = Manifest.find_by_uuid_or_tracking_number(params[:manifest_id])
    @success_message = "All done! Manifest #{manifest.tracking_number} has been signed and submitted."
  end

  private

  def secret_question_params
    params.fetch(:secret_question, {}).permit(
      :answer,
      :activity_id,
      :token,
      :user_id,
      :question_id,
    )
  end
end

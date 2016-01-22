class SignaturesController < ApplicationController
  def new
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:manifest_id])
    @response = parsed_response_params
  end

  def create
    @manifest = Manifest.find_by_uuid_or_tracking_number(params[:manifest_id])
    cdx_response = CDX::Manifest.new(signature_params.symbolize_keys).sign

    if cdx_response.key?(:document_id)
      redirect_to manifest_signature_path(@manifest.uuid)
    else
      flash.now[:error] = cdx_response[:description]
      @response = signature_params
      render :new
    end
  end

  def show
    manifest = Manifest.find_by_uuid_or_tracking_number(params[:manifest_id])
    @success_message = "All done! Manifest #{manifest.tracking_number} has been signed and submitted."
  end

  private

  def signature_params
    params.fetch(:secret_question, {}).permit(
      :activity_id,
      :answer,
      :question,
      :question_id,
      :token,
      :user_id,
    )
  end

  def parsed_response_params
    params[:response][:question_id] = question_params[:question_id]
    params[:response][:question] = question_params[:question_text]
    params[:response]
  end

  def question_params
    params[:response][:question]
  end
end

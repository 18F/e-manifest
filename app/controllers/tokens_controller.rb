class TokensController < ApplicationController
  def new
    @manifest = Manifest.find(params[:manifest_id])
  end

  def create
    @manifest = Manifest.find(params[:manifest_id])

    response = CDX::Authenticator.new(auth_params).perform

    if response[:question]
      redirect_to new_manifest_signature_path(@manifest)
    else
      flash[:error] = "Username and password are not valid"
      render :new
    end
  end

  private

  def auth_params
    params.fetch(:token, {}).permit(:user_id, :password)
  end
end

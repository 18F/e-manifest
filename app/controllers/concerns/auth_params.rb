module AuthParams
  def auth_params
    params.fetch(:token, {}).permit(:user_id, :password)
  end
end

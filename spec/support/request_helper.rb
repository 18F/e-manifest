module RequestHelper
  def login_as(user, cdx_response = nil)
    UserSession.create(user, cdx_response)
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    UserSession.namespace = "test_user_session"
    UserSession.flush_all
  end

  config.after(:suite) do
    UserSession.flush_all
  end
end

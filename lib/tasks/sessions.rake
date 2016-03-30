namespace :sessions do
  desc 'clear all sessions'
  task clear: :environment do
    UserSession.flush_all
  end
end

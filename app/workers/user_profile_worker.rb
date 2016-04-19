class UserProfileWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true, backtrace: true

  def perform(user_id, dataflow = ENV['CDX_DEFAULT_DATAFLOW'])
    user = User.find(user_id)
    user.cdx_sync(dataflow)
  end
end

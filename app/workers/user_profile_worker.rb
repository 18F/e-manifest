class UserProfileWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true, backtrace: true

  def perform(user_id, dataflow = ENV['CDX_DEFAULT_DATAFLOW'])
    user = User.find(user_id)
    builder = UserProfileBuilder.new(user, dataflow)
    profile = builder.run
    puts profile.pretty_inspect
    syncer = UserProfileSyncer.new(user, profile)
    syncer.run
  end
end

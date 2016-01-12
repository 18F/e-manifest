worker: bundle exec sidekiq -C config/sidekiq.yml
web: bundle exec puma -p ${PORT:-3000} -C ./config/puma.rb

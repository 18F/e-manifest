source 'https://rubygems.org'

ruby '2.2.3'

gem 'activerecord'
gem 'ansi'
gem 'dotenv'
gem 'foreman'
gem 'json-patch'
gem 'jekyll'
gem 'pg'
gem 'pry'
gem 'rack-contrib'
gem 'rake'
gem 'redcarpet'
gem 'savon-multipart'
gem 'sidekiq'
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'thin'

# IMPORTANT these ES gems are clustered together because
# load order is important
gem 'kaminari'
gem 'elasticsearch-dsl'
gem 'elasticsearch-model'

group :development, :test do
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'elasticsearch-extensions'
  gem 'json_matchers'
  gem 'queryparams'
  gem 'webmock'
end

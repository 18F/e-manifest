require './app'
require 'sinatra/activerecord/rake'

task default: 'build'

# Build Jekyll static site
task :build do
  system '( cd _static/ ; jekyll build --destination ../public )'
end

task :build_dev do
  system '( cd _static/ ; jekyll build --watch --destination ../public )'
end

# Serve the Ruby/Sinatra app
# Start local postgres DB using:
#   postgres -D /usr/local/var/postgres
task :serve do
  Rake::Task['build'].invoke

  system 'rackup'
end

task :serve_dev do
  # Run `rake build_dev` in another terminal to get auto-reloading
  system 'rackup'
end

# Push to Cloud Foundry
task :deploy do
  Rake::Task['build'].invoke
  system 'cf push'
end

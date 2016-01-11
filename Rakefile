require File.dirname(__FILE__) + "/lib/app"
require 'sinatra/activerecord/rake'
Dir.glob('lib/tasks/*.rake').each { |r| load r}

task default: 'build'

desc 'Build Jekyll static site'
task :build do
  system '( cd _static/ ; jekyll build --destination ../public )'
end

desc 'Build and watch for dev mode: Jekyll static site'
task :build_dev do
  system '( cd _static/ ; jekyll build --watch --destination ../public )'
end

desc 'Build jekyll and serve the sinatra app'
task :serve do
  Rake::Task['build'].invoke
  system 'PORT=9292 script/start'
end

desc 'Deceptive name: just runs Sinatra without building Jekyll'
task :serve_dev do
  # Run `rake build_dev` in another terminal to get auto-reloading
  system 'rackup'
end

desc 'Push to Cloud Foundry'
task :deploy do
  Rake::Task['build'].invoke
  system 'cf push'
end

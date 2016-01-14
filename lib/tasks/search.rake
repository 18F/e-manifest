require 'elasticsearch/rails/ha/tasks'

namespace :search do
  desc 're-index all records, in parallel'
  task index: :environment do
    ENV['CLASS'] = 'Manifest'
    Rake::Task['elasticsearch:ha:import'].invoke
    Rake::Task['elasticsearch:ha:import'].reenable
  end
end

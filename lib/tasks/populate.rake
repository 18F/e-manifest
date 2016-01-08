require 'rake'
require_relative File.dirname(__FILE__) + '/../../../chores/populator.rb'

namespace :populate do
  desc "populate database with dummy manifests"
  task :manifests do
    populator = Populator.new(Manifest, ENV["NRECORDS"])
    populator.run
  end
end

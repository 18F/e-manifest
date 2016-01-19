require 'rake'
require_relative File.dirname(__FILE__) + '../../../db/chores/populator.rb'

namespace :populate do
  desc "populate database with dummy manifests"
  task manifests: :environment do
    populator = Populator.new(Manifest, ENV["NRECORDS"], ENV["RANDOMIZE_CREATED_AT"])
    populator.run
  end
end

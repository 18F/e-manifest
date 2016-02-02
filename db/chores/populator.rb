require "json"
require_relative '../../app/helpers/example_json_helper'

class Populator
  include ExampleJsonHelper

  def initialize(model, n_records=100, randomize_created_at=false)
    @model = model
    @n_records = (n_records || 100).to_i
    @randomize_created_at = randomize_created_at
  end

  def run(n_records=@n_records)
    method_name = "make_#{@model.to_s.downcase}_record".to_sym
    unless respond_to?(method_name, true)
      fail "#{@model} not supported -- no method #{method_name}"
    end
    n_records.times do |i|
      model_instance = @model.create( send( method_name, i ) )
      if @randomize_created_at
        model_instance.update_column(:created_at, random_time)
      end
    end 
  end

  private

  def random_time
    Time.at(rand * Time.now.to_i)
  end

  def make_manifest_record(iteration)
    manifest = read_example_json_file_as_json('manifest')
    user = User.find_or_create('unknown_user')
    manifest[:my_id] = iteration
    manifest["generator"]["name"] = "#{random_string()[0..8]} Generator"
    manifest["designated_facility"]["name"] = "#{random_string()[0..8]} Facility"
    manifest["generator"]["manifest_tracking_number"] = random_tracking_number
    { user: user, content: manifest.to_json }
  end

  def random_string
    SecureRandom.hex
  end
end

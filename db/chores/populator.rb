require "json"

class Populator
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
    manifest = JSON.parse(manifest_template)
    manifest[:my_id] = iteration
    manifest["generator"]["name"] = "#{random_string()[0..8]} Generator"
    manifest["designated_facility"]["name"] = "#{random_string()[0..8]} Facility"
    manifest["generator"]["manifest_tracking_number"] = SecureRandom.random_number(1_000_000_000)
    { content: manifest.to_json }
  end

  def manifest_template
    File.read(Rails.root.join('app', 'views', 'examples', '_manifest.json'))
  end

  def random_string
    SecureRandom.hex
  end
end

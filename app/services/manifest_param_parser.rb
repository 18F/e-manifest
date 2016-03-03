class ManifestParamParser
  def initialize(params)
    @manifest_params = params[:manifest]
  end

  def run
    if manifest_params
      remove_extra_params
      parse_manifest_item_params
    end
  end

  private

  attr_reader :manifest_params

  def remove_extra_params
    manifest_params.delete(:international)

    if manifest_params[:generator]
      manifest_params[:generator].delete(:site_address_same_as_mailing)
    end

    if manifest_params[:designated_facility]
      manifest_params[:designated_facility].delete(:shipment_has_discrepancy)
    end
  end

  def parse_manifest_item_params
    if manifest_params[:manifest_items].try(:any?)
      manifest_params[:manifest_items].each do |item|
        parse_manifest_item(item)
      end
    end
  end

  def parse_manifest_item(item)
    item[:number_of_containers] = convert_to_integer(item[:number_of_containers])
    item[:total_quantity] = convert_to_integer(item[:total_quantity])
    item[:hazardous_material] = convert_to_boolean(item[:hazardous_material])
    item[:hazard_classes] = convert_to_array(item[:hazard_classes])
    item[:state_waste_codes] = convert_to_array(item[:state_waste_codes])
    item[:epa_waste_codes] = convert_to_array(item[:epa_waste_codes])
  end

  def convert_to_integer(key)
    if key
      key = key.to_i
    end
  end

  def convert_to_boolean(key)
    if key == "True"
      key = true
    elsif key == "False"
      key = false
    end
  end

  def convert_to_array(key)
    if key
      key = key.split(',').flatten
    end
  end
end

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
    <<-JSON
{
  "generator": {
    "name": "Generator Y",
    "us_epa_id_number": "112712334321",
    "manifest_tracking_number": "98876761",
    "emergency_response_phone": "888-999-8888",
    "phone_number": "800-883-1731",
    "mailing_address": {
      "address_1": "88 Generator Way",
      "address_2": "Loop 19",
      "city": "Looptown",
      "state": "LA",
      "zip_code": "71291"
    },
    "site_address_same_as_mailing_address": "no",
    "site_address": {
      "address_1": "123 Site Place",
      "address_2": "Around the Corner",
      "city": "Cornerville",
      "state": "CA",
      "zip_code": "93818"
    },
    "signatory": {
      "name": "Bob Smith",
      "month": "6",
      "day": "6",
      "year": "2015"
    },
    "no_us_epa_id_number": false
  },
  "transporters": [
    {
      "company_name": "Transporter National",
      "us_epa_id_number": "3881",
      "signatory": {
        "name": "Jill Jones",
        "month": "7",
        "day": "7",
        "year": "2015"
      }
    }
  ],
  "is_international_shipment": "yes",
  "international_shipment": {
    "date_leaving_us": {
      "month": "10",
      "day": "22",
      "year": "2015"
    },
    "export_import": "export_from_us",
    "port_of_entry_exit": "Savannah, GA"
  },
  "designated_facility": {
    "name": "Facility Zero",
    "us_epa_id_number": "9238754",
    "phone_number": "888-848-1318",
    "certification": {
      "name": "Betty Black",
      "month": "10",
      "day": "1",
      "year": "2015"
    },
    "address": {
      "address_1": "360 Zero Circle",
      "address_2": "Two Pi",
      "city": "Pie Town",
      "state": "PA",
      "zip_code": "23171"
    },
    "has_discrepancy": true,
    "discrepancy": {
      "name": "Alternate Facility Y",
      "us_epa_id_number": "1734",
      "phone_number": "877-577-2771",
      "category_quantity": true,
      "type": "no_rejection",
      "description": "Only received 940 quarts of shoes.",
      "signatory": {
        "name": "Johnny Appleseed",
        "month": "8",
        "day": "8",
        "year": "2015"
      },
      "address": {
        "address_1": "88 Alternate Av",
        "address_2": "Ste 671",
        "city": "Alternative",
        "state": "AK",
        "zip_code": "91919"
      }
    }
  },
  "manifest_items": [
    {
      "total_quantity": "99",
      "unit_wt_vol": "G",
      "proper_shipping_name": "Hazardous Stuff",
      "id_number": "771",
      "state_waste_codes": [
        "State1",
        "state2"
      ],
      "epa_waste_codes": [
        "Fed1",
        "Fed2"
      ],
      "packing_group": "Twelve",
      "container_type": "BA",
      "number_of_containers": "8",
      "hazard_classes": ["6", "8"],
      "hazardous_material": "yes"
    },
    {
      "total_quantity": "953",
      "unit_wt_vol": "Q",
      "proper_shipping_name": "Old Shoes",
      "id_number": "671",
      "state_waste_codes": [
        "Else"
      ],
      "epa_waste_codes": [
        "Something"
      ],
      "packing_group": "81988931",
      "container_type": "CR",
      "number_of_containers": "12",
      "hazard_classes": [],
      "hazardous_material": "no"
    }
  ],
  "waste_pcb_description": "None.",
  "waste_non_hazardous_material_present": "yes",
  "waste_handling_instructions": "Do not feed after midnight.",
  "report_management_method_codes": [
    "Method1",
    "Method2",
    "Method3"
  ]
}
    JSON
  end

  def random_string
    SecureRandom.hex
  end
end

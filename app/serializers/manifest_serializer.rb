class ManifestSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :activity_id,
    :created_on,
    :document_id,
    :content
  )

  def id
    object.uuid
  end

  def created_on
    object.created_on
  end

  def generator
    object.content["generator"] || {}
  end

  def transporters
    object.content["transporters"] || {}
  end

  def designated_facility
    object.content["designated_facility"] || {}
  end

  def manifest_items
    object.content["manifest_items"] || {}
  end

  def waste_pcb_description
    object.content["waste_pcb_description"]
  end

  def waste_non_hazardous_material_present
    object.content["waste_non_hazardous_material_present"]
  end

  def waste_handling_instructions
    object.content["waste_handling_instructions"]
  end

  def report_management_method_codes
    object.content["report_management_method_codes"]
  end
end

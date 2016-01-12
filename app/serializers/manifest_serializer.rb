class ManifestSerializer < ActiveModel::Serializer
  attributes(
    :activity_id,
    :created_on,
    :document_id,
    :generator,
    :transporters,
    :designated_facility,
    :manifest_items,
    :waste_pcb_description,
    :waste_non_hazardous_material_present,
    :waste_handling_instructions,
    :report_management_method_codes,
  )

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

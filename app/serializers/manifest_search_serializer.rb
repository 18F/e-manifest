class ManifestSearchSerializer < ActiveModel::Serializer
  attributes(
    :took,
    :total,
    :hits
  )

  def took
    object.took
  end

  def total
    object.results.total
  end

  def hits
    ActiveModel::ArraySerializer.new(object.records.to_a, each_serializer: ManifestSerializer)
  end
end

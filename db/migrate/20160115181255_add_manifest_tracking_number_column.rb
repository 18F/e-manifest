class AddManifestTrackingNumberColumn < ActiveRecord::Migration
  class Manifest < ActiveRecord::Base
  end

  def up
    add_column :manifests, :tracking_number, :string

    Manifest.all.each do |manifest|
      tracking_number = "undefined-tracking-number-#{manifest.id}"
      if manifest.content && manifest.content['generator'] && manifest.content['generator']['manifest_tracking_number']
        tracking_number = manifest.content['generator']['manifest_tracking_number']
      end
      manifest.update_column(:tracking_number, tracking_number)
    end

    change_column :manifests, :tracking_number, :string, null: false, unique: true
  end

  def down
    remove_column :manifests, :tracking_number
  end
end

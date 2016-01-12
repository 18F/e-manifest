class AddUuidToManifests < ActiveRecord::Migration
  def up
    add_column :manifests, :uuid, :uuid

    Manifest.all.each do |manifest|
      manifest.update_column(:uuid, SecureRandom.uuid)
    end

    change_column :manifests, :uuid, :uuid, unique: true
    add_index :manifests, :uuid, unique: true
  end

  def down
    remove_column :manifests, :uuid
  end
end

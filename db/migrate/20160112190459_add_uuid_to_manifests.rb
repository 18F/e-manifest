class AddUuidToManifests < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'
    add_column :manifests, :uuid, :uuid

    Manifest.all.each do |manifest|
      manifest.update_column(:uuid, SecureRandom.uuid)
    end

    change_column :manifests, :uuid, :uuid, unique: true, default: 'uuid_generate_v4()'
    add_index :manifests, :uuid, unique: true
  end

  def down
    disable_extension 'uuid-ossp'
    remove_column :manifests, :uuid
  end
end

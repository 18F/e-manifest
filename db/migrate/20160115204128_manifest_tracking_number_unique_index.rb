class ManifestTrackingNumberUniqueIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
      create unique index manifest_tracking_number_idx on manifests ((content->'generator'->>'manifest_tracking_number'));
    SQL
  end

  def down
    remove_index :manifests, name: :manifest_tracking_number_idx
  end
end

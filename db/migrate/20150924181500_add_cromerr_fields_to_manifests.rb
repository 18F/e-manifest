class AddCromerrFieldsToManifests < ActiveRecord::Migration
  def self.up
    add_column :manifests, :activity_id, :string
    add_column :manifests, :document_id, :string
 end
  def self.down
    remove_column :manifests, :activity_id
    remove_column :manifests, :document_id
 end
end

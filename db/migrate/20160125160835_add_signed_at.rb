class AddSignedAt < ActiveRecord::Migration
  def up
    add_column :manifests, :signed_at, :datetime
  end

  def down
    remove_column :manifests, :signed_at
  end
end

class AddManifestsUserId < ActiveRecord::Migration
  def up
    execute "INSERT INTO users (id, cdx_user_id, created_at, updated_at) VALUES (0, 'unknown_user', now(), now())"
    add_column :manifests, :user_id, :integer, null: false, default: 0
    add_index :manifests, :user_id
    execute "ALTER TABLE manifests ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
  end

  def down
    execute "ALTER TABLE manifests DROP CONSTRAINT user_id_fkey"
    remove_index :manifests, :user_id
    remove_column :manifests, :user_id
    execute "DELETE FROM users WHERE id=0"
  end
end

class AddUsers < ActiveRecord::Migration
  def change
    create_table :users do |table|
      table.string :cdx_user_id, null: false
      table.timestamps null: false
    end
    add_index :users, :cdx_user_id, unique: true
  end
end

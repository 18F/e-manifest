class AddCdxOrgRoles < ActiveRecord::Migration
  def up
    create_table :organizations do |table|
      table.string :cdx_org_name, null: false
      table.string :cdx_org_id, null: false
      table.timestamps null: false
    end

    create_table :roles do |table|
      table.string :cdx_role_name, null: false
      table.string :cdx_role_code, null: false
      table.timestamps null: false
    end

    create_table :user_org_roles do |table|
      table.integer :organization_id, null: false
      table.integer :role_id, null: false
      table.integer :user_id, null: false
      table.string :cdx_user_role_id, null: false
      table.string :cdx_status, null: false
      table.timestamps null: false
    end

    add_index :organizations, [:cdx_org_name, :cdx_org_id], unique: true
    add_index :organizations, :cdx_org_name
    add_index :roles, [:cdx_role_name, :cdx_role_code], unique: true
    add_index :roles, :cdx_role_name
    add_index :user_org_roles, [:organization_id, :role_id, :user_id], unique: true
    add_index :user_org_roles, :organization_id
    add_index :user_org_roles, :role_id
    add_index :user_org_roles, :user_id

    execute "ALTER TABLE user_org_roles ADD CONSTRAINT organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id)"
    execute "ALTER TABLE user_org_roles ADD CONSTRAINT role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id)"
    execute "ALTER TABLE user_org_roles ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
  end

  def down
    drop_table :user_org_roles
    drop_table :roles
    drop_table :organizations
  end
end

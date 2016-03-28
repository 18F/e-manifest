class AddProfileToRoles < ActiveRecord::Migration
  def change
    add_column :user_org_roles, :profile, :json
  end
end

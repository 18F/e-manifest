class AddAddressToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :profile, :json
  end
end

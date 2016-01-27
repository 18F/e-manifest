class CreateTransporters < ActiveRecord::Migration
  def change
    create_table :transporters do |t|
      t.string :us_epa_id_number
      t.string :name
      t.belongs_to :manifest, index: true, null: false
    end
  end
end

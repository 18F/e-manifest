class CreateManifests < ActiveRecord::Migration
 def self.up
   create_table :manifests do |t|
     t.json :content
     t.timestamps null: false
   end
 end

 def self.down
   drop_table :manifests
 end
end

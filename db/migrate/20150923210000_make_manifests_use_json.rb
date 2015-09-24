class MakeManifestsUseJson < ActiveRecord::Migration
 def self.up
   execute "alter table manifests alter column content set data type json using (content::json);"
 end

 def self.down
   execute "alter table manifests alter column content set data type text;"
 end
end

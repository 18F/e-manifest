class ManifestsToJsonb < ActiveRecord::Migration
  def up
    execute <<-SQL
      alter table manifests alter column content set data type jsonb using content::jsonb;
    SQL
  end

  def down
    execute <<-SQL
      alter table manifests alter column content set data type json using content::json;
    SQL
  end
end

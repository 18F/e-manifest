class AddTransactionIdRenameSignedToSubmittedAt < ActiveRecord::Migration
  def up
    add_column :manifests, :transaction_id, :string
    rename_column :manifests, :signed_at, :submitted_at
  end

  def down
    remove_column :manifests, :transaction_id
    rename_column :manifests, :submitted_at, :signed_at
  end
end

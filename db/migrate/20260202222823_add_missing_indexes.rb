class AddMissingIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :family_invitations, :token, unique: true
    add_index :issues, :root_issue_id
    add_index :issues, [:family_id, :status]
  end
end

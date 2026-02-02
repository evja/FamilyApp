class UpdateIssueStatusAndAddResolvedAt < ActiveRecord::Migration[7.1]
  def up
    change_column_default :issues, :status, "new"
    Issue.where(status: "open").update_all(status: "new")
    add_column :issues, :resolved_at, :datetime
  end

  def down
    remove_column :issues, :resolved_at
    Issue.where(status: "new").update_all(status: "open")
    change_column_default :issues, :status, "open"
  end
end

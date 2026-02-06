class StandardizeIssueListTypes < ActiveRecord::Migration[7.1]
  def up
    Issue.where(list_type: "Family").update_all(list_type: "family")
    Issue.where(list_type: "Marriage").update_all(list_type: "parent")
    Issue.where(list_type: "Personal").update_all(list_type: "individual")
    Issue.where(list_type: nil).update_all(list_type: "family")
  end

  def down
    # No rollback needed - lowercase values are compatible
  end
end

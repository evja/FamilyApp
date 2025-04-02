class CreateIssues < ActiveRecord::Migration[7.1]
  def change
    create_table :issues do |t|
      t.references :family, null: false, foreign_key: true
      t.string :list_type                     # "Family", "Marriage", "Personal"
      t.text :description                     # Full issue description (no title)
      t.string :category                      # User-defined category
      t.string :urgency                       # Low, Medium, High
      t.string :status, default: "open"       # Open, In Progress, Resolved
      t.string :issue_type                    # "symptom" or "root"
      t.integer :root_issue_id                # Foreign key to self

      t.timestamps
    end
  end
end

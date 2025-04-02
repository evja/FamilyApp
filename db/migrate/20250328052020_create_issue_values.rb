class CreateIssueValues < ActiveRecord::Migration[7.1]
  def change
    create_table :issue_values do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :family_value, null: false, foreign_key: true

      t.timestamps
    end
  end
end

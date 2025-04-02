class CreateIssueMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :issue_members do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
  end
end

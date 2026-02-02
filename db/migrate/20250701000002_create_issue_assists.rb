class CreateIssueAssists < ActiveRecord::Migration[7.1]
  def change
    create_table :issue_assists do |t|
      t.references :family, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :original_text
      t.text :suggested_text

      t.timestamps
    end

    add_index :issue_assists, [:family_id, :created_at]
  end
end

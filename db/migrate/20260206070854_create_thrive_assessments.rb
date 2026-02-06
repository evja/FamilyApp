class CreateThriveAssessments < ActiveRecord::Migration[7.1]
  def change
    create_table :thrive_assessments do |t|
      t.references :member, null: false, foreign_key: true
      t.references :completed_by, foreign_key: { to_table: :users }
      t.references :rhythm_completion, foreign_key: true, null: true

      t.integer :mind_rating
      t.integer :body_rating
      t.integer :spirit_rating
      t.integer :responsibility_rating

      t.text :mind_notes
      t.text :body_notes
      t.text :spirit_notes
      t.text :responsibility_notes

      t.text :whats_working
      t.text :whats_not_working
      t.text :action_items

      t.datetime :assessed_at, null: false
      t.timestamps
    end

    add_index :thrive_assessments, [:member_id, :assessed_at]
  end
end

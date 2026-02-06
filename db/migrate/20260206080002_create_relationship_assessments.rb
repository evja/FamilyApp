class CreateRelationshipAssessments < ActiveRecord::Migration[7.1]
  def change
    create_table :relationship_assessments do |t|
      t.references :relationship, null: false, foreign_key: true
      t.references :assessor, foreign_key: { to_table: :users }
      t.references :rhythm_completion, foreign_key: true, null: true

      t.date :assessed_on, null: false
      t.string :quarter_key

      t.integer :score_cooperation, null: false
      t.integer :score_affection, null: false
      t.integer :score_trust, null: false
      t.integer :total_score

      t.text :whats_working
      t.text :whats_not_working
      t.text :action_items

      t.timestamps
    end

    add_index :relationship_assessments, [:relationship_id, :assessed_on]
    add_index :relationship_assessments, [:relationship_id, :quarter_key]
  end
end

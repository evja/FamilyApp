class CreateRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :relationships do |t|
      t.references :family, null: false, foreign_key: true
      t.references :member_low, null: false, foreign_key: { to_table: :members }
      t.references :member_high, null: false, foreign_key: { to_table: :members }
      t.string :relationship_type
      t.integer :current_health_score
      t.string :current_health_band
      t.datetime :last_assessed_at

      t.timestamps
    end

    add_index :relationships, [:family_id, :member_low_id, :member_high_id],
              unique: true, name: 'idx_relationships_unique_pair'
    add_index :relationships, :current_health_band
  end
end

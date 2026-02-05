class CreateRhythms < ActiveRecord::Migration[7.1]
  def change
    create_table :rhythms do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.string :frequency_type, null: false, default: 'weekly'
      t.integer :frequency_days, null: false, default: 7
      t.boolean :is_active, default: true
      t.datetime :next_due_at
      t.datetime :last_completed_at
      t.string :rhythm_category, default: 'custom'
      t.text :description
      t.timestamps
    end

    add_index :rhythms, [:family_id, :is_active]
    add_index :rhythms, :next_due_at
  end
end

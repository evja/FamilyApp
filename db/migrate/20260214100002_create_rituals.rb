class CreateRituals < ActiveRecord::Migration[7.1]
  def change
    create_table :rituals do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :ritual_type, null: false
      t.string :frequency
      t.text :purpose
      t.boolean :is_active, default: true
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :rituals, [:family_id, :is_active]
    add_index :rituals, [:family_id, :ritual_type]

    create_table :ritual_components do |t|
      t.references :ritual, null: false, foreign_key: true
      t.string :component_type, default: "perform"
      t.string :title, null: false
      t.text :description
      t.integer :duration_minutes
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :ritual_components, [:ritual_id, :position]

    create_table :ritual_values do |t|
      t.references :ritual, null: false, foreign_key: true
      t.references :family_value, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ritual_values, [:ritual_id, :family_value_id], unique: true
  end
end

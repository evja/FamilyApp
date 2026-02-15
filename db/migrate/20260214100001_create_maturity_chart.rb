class CreateMaturityChart < ActiveRecord::Migration[7.1]
  def change
    create_table :maturity_levels do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color_code
      t.integer :age_min
      t.integer :age_max
      t.integer :position, default: 0
      t.text :description

      t.timestamps
    end

    add_index :maturity_levels, [:family_id, :position]

    create_table :maturity_behaviors do |t|
      t.references :maturity_level, null: false, foreign_key: true
      t.string :category
      t.text :description, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :maturity_behaviors, [:maturity_level_id, :category]

    create_table :maturity_privileges do |t|
      t.references :maturity_level, null: false, foreign_key: true
      t.string :category
      t.text :description, null: false
      t.string :value
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :maturity_privileges, [:maturity_level_id, :category]
  end
end

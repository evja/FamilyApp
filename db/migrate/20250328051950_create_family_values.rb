class CreateFamilyValues < ActiveRecord::Migration[7.1]
  def change
    create_table :family_values do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end

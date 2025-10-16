class CreateFamilyVisions < ActiveRecord::Migration[7.1]
  def change
    create_table :family_visions do |t|
      t.references :family, null: false, foreign_key: true
      t.text :mission_statement
      t.text :notes

      t.timestamps
    end
  end
end

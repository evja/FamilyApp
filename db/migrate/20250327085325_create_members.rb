class CreateMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :members do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name
      t.integer :age
      t.text :personality
      t.text :interests
      t.text :health
      t.text :development
      t.text :needs

      t.timestamps
    end
  end
end

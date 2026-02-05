class CreateAgendaItems < ActiveRecord::Migration[7.1]
  def change
    create_table :agenda_items do |t|
      t.references :rhythm, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :title, null: false
      t.integer :duration_minutes
      t.text :instructions
      t.string :link_type, default: 'none'
      t.timestamps
    end

    add_index :agenda_items, [:rhythm_id, :position]
  end
end

class CreateCompletionItems < ActiveRecord::Migration[7.1]
  def change
    create_table :completion_items do |t|
      t.references :rhythm_completion, null: false, foreign_key: true
      t.references :agenda_item, null: false, foreign_key: true
      t.boolean :checked, default: false
      t.datetime :checked_at
      t.text :notes
      t.timestamps
    end

    add_index :completion_items, [:rhythm_completion_id, :agenda_item_id], unique: true, name: 'index_completion_items_on_completion_and_agenda'
  end
end

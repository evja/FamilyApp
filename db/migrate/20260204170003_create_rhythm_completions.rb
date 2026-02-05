class CreateRhythmCompletions < ActiveRecord::Migration[7.1]
  def change
    create_table :rhythm_completions do |t|
      t.references :rhythm, null: false, foreign_key: true
      t.references :completed_by, foreign_key: { to_table: :users }
      t.datetime :started_at
      t.datetime :completed_at
      t.text :notes
      t.string :status, default: 'in_progress'
      t.timestamps
    end

    add_index :rhythm_completions, [:rhythm_id, :completed_at]
  end
end

class CreateGameChronicleEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :game_chronicle_entries do |t|
      t.uuid :game_id, null: false
      t.string :event_type, null: false
      t.datetime :occurred_at
      t.text :text, null: false

      t.timestamps
    end

    add_index :game_chronicle_entries, :game_id
  end
end

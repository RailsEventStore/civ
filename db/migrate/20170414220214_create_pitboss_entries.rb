class CreatePitbossEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :pitboss_entries do |t|
      t.string :game_name
      t.string :player_name
      t.string :entry_type
      t.decimal :timestamp, precision: 20, scale: 3

      t.timestamps
    end
  end
end

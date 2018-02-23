class CreatePlayerStats < ActiveRecord::Migration[5.1]
  def change
    create_table :player_stats do |t|
      t.uuid :player_id, null: false
      t.integer :turns_taken, default: 0
      t.integer :turns_last, default: 0
    end

    add_index :player_stats, :player_id, unique: true
  end
end

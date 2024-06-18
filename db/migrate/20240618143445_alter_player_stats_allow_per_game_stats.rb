class AlterPlayerStatsAllowPerGameStats < ActiveRecord::Migration[7.0]
  def change
    remove_index(:player_stats, :player_id)

    add_column(:player_stats, :game_id, :string, after: :player_id, null: false, default: "all")

    add_index(:player_stats, [:player_id, :game_id])
  end
end

class AddUnfinishedPlayerIdsToReadModelGames < ActiveRecord::Migration[7.0]
  def change
    add_column(:read_model_games, :unfinished_player_ids, :jsonb, default: [])
  end
end

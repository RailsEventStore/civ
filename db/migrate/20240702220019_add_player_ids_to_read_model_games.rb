class AddPlayerIdsToReadModelGames < ActiveRecord::Migration[7.0]
  def change
    add_column(:read_model_games, :player_ids, :jsonb, default: [])
  end
end

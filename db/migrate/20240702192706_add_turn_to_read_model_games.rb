class AddTurnToReadModelGames < ActiveRecord::Migration[7.0]
  def change
    add_column(:read_model_games, :current_turn, :jsonb, default: {})
  end
end

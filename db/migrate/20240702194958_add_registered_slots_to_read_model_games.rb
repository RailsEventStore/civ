class AddRegisteredSlotsToReadModelGames < ActiveRecord::Migration[7.0]
  def change
    add_column(:read_model_games, :registered_slots, :jsonb, default: {})
  end
end

class AddNumberOfRemainingPlayersToNotifyToReadModelGames < ActiveRecord::Migration[5.1]
  def change
    add_column :read_model_games, :number_of_remaining_players_to_notify, :integer, null: false, default: 1
  end
end

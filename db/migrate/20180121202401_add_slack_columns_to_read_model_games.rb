class AddSlackColumnsToReadModelGames < ActiveRecord::Migration[5.1]
  def change
    add_column :read_model_games, :slack_token, :string
    add_column :read_model_games, :slack_channel, :string
    add_column :read_model_games, :ip_address, :string
  end
end

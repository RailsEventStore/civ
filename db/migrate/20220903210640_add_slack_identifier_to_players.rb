class AddSlackIdentifierToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :slack_identifier, :string, after: "slack_name"
  end
end

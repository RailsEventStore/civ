class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players, id: :uuid do |t|
      t.string :steam_name, null: false
      t.string :slack_name, null: false

      t.timestamps
    end
  end
end

class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :read_model_games, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end

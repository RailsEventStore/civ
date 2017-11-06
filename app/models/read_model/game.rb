module ReadModel
  class Game < ApplicationRecord
    self.table_name = 'read_model_games'

    def self.handle_game_hosted(event)
      create!(
        id: event.data.fetch(:game_id),
        name: 'Untitled game'
      )
    end
  end
end

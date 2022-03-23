module ReadModel
  class GameReadModel < ApplicationRecord
    self.table_name = "read_model_games"

    def self.handle_game_hosted(event)
      create!(id: event.data.fetch(:game_id), name: "Untitled game")
    end

    def build_slack_new_turn_message(event_data)
      "Game #{name} Turn #{event_data[:turn]} <!channel>
steam://run/8930/q/%2Bconnect%20#{ip_address}"
    end
  end
end

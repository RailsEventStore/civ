module ReadModel
  class GameReadModel < ApplicationRecord
    self.table_name = "read_model_games"

    serialize :current_turn
    serialize :unfinished_player_ids
    serialize :registered_slots
    serialize :player_ids

    def self.handle_game_hosted(event)
      create!(
        id: event.data.fetch(:game_id),
        name: "Untitled game",
        current_turn: {timer: event.data.fetch(:turn_timer).to_i, number: 0}
      )
    end

    def build_slack_new_turn_message(event_data)
      "Game #{name} Turn #{event_data[:turn]} <!channel>
steam://run/8930/q/%2Bconnect%20#{ip_address}"
    end

    def build_slack_timer_reset_message(event_data, player = nil)
      player_name = player&.slack_name || "Unknown player"
      "The turn timer for game #{name} has been reset by #{player_name}"
    end

    def turn
      current_turn[:number]
    end

    def ends_at
      Time.at(current_turn[:ends_at].to_i)
    end
  end
end

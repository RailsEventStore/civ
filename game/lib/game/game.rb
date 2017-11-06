require 'aggregate_root'

module Game
  class Game
    include AggregateRoot

    def initialize(id)
      @id = id
    end

    def host_game(turn_timer)
      apply(GameHosted.new(data: {
        turn_timer: turn_timer,
        game_id: @id,
      }))
    end

    def register_player(player_id, slot_id)
      apply(PlayerRegistered.new(data: {
        player_id: player_id,
        slot_id: slot_id,
        game_id: @id,
      }))
    end

    private

    def apply_player_registered(_event)
    end

    def apply_game_hosted(_event)
    end
  end
end
require 'aggregate_root'

module Game
  class Play
    include AggregateRoot

    def initialize(id)
      @id = id
    end

    def register_player(player_id, slot_id)
      apply(PlayerRegistered.new(data: {
        player_id: player_id,
        slot_id: slot_id,
        play_id: @id,
      }))
    end

    private

    def apply_player_registered(_event)
    end
  end
end
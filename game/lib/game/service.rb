module Game
  class Service
    def initialize(event_store)
      @event_store = event_store
    end

    def setup_game(cmd)
      with_game(cmd.game_id) do |game|
        game.setup_game(cmd.turn_timer)
      end
    end

    def register_player(cmd)
      with_game(cmd.game_id) do |game|
        game.register_player(cmd.player_id, cmd.slot_id)
      end
    end

    private

    def with_game(id)
      game        = Game.new(id)
      stream_name = "Game$#{id}"
      game.load(stream_name, event_store: @event_store)
      yield game
      game.store(stream_name, event_store: @event_store)
    end
  end
end
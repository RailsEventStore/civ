module Game
  class Service
    def initialize(event_store)
      @event_store = event_store
    end

    def host_game(cmd)
      with_game(cmd.game_id) { |game| game.host_game(cmd.turn_timer) }
    end

    def register_player(cmd)
      with_game(cmd.game_id) { |game| game.register_player(cmd.player_id, cmd.slot_id) }
    end

    def unregister_player(cmd)
      with_game(cmd.game_id) { |game| game.unregister_player(cmd.player_id, cmd.slot_id) }
    end

    private

    def with_game(id)
      repo = AggregateRoot::Repository.new(@event_store)
      game = repo.load(Game.new(id), stream_name = "Game$#{id}")
      yield game
      repo.store(game, stream_name)
    end
  end
end

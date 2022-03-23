require_relative "../spec_helper"

module Game
  RSpec.describe Service do
    include InMemoryEventStore

    def game_id
      "c1f89f49-ec8f-422e-a858-6c9bb1f2fce0"
    end

    def game_stream
      "Game$#{game_id}"
    end

    def player_id
      "7f27f9b8-38fd-4c1d-b26d-fd7193ac1be4"
    end

    def slot_id
      0
    end

    specify do
      service = Service.new(event_store)
      service.host_game(HostGame.new(game_id, 24.hours))

      expect(event_store).to have_published(GameHosted).in_stream(game_stream)
    end

    specify do
      service = Service.new(event_store)
      service.register_player(RegisterPlayer.new(game_id, player_id, slot_id))

      expect(event_store).to have_published(PlayerRegistered).in_stream(game_stream)
    end

    specify do
      service = Service.new(event_store)
      service.unregister_player(UnregisterPlayer.new(game_id, player_id, slot_id))

      expect(event_store).to have_published(PlayerUnregistered).in_stream(game_stream)
    end
  end
end

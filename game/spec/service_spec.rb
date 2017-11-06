module Game
  RSpec.describe Service do
    include InMemoryEventStore

    def game_id
      'c1f89f49-ec8f-422e-a858-6c9bb1f2fce0'
    end

    def game_stream
      "Game$#{game_id}"
    end

    specify do
      service = Service.new(event_store)
      service.setup_game(SetupGame.new(game_id, 24.hours))

      expect(event_store).to have_published(GameHosted).in_stream(game_stream)
    end
  end
end

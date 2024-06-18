require "rails_event_store"

module Game
  class Players
    Result = Struct.new(:player_ids)
    private_constant :Result

    def initialize(event_store)
      @event_store = event_store
    end

    def call(stream_name)
      state = RailsEventStore::Projection
        .from_stream(stream_name)
        .init(method(:initial_state))
        .when(PlayerRegistered, method(:handle_player_registered))
        .run(@event_store, count: 10_000)
      Result.new(state[:player_ids])
    end

    private

    def initial_state
      {player_ids: []}
    end

    def handle_player_registered(state, event)
      state[:player_ids] << event.data.fetch(:player_id)
      state
    end
  end
end

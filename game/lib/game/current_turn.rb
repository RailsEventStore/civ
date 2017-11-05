require 'rails_event_store'

module Game
  class CurrentTurn
    Result = Struct.new(:turn, :done, :started_at)
    private_constant :Result

    def initialize(event_store)
      @event_store = event_store
      @projection =
        RailsEventStore::Projection
          .from_all_streams
          .init(method(:initial_state))
          .when(PlayerRegistered, method(:handle_player_registered))
          .when(NewTurnStarted, method(:handle_new_turn))
          .when(PlayerEndedTurn, method(:handle_player_ended_turn))
          .when(PlayerEndTurnCancelled, method(:handle_player_end_turn_cancelled))
    end

    def call
      state = @projection.run(@event_store)
      Result.new(state[:turn], state[:done_player_ids], state[:started_at])
    end

    private

    def initial_state
      {
        registered_slots: {},
        turn: 0,
        started_at: nil,
        done_player_ids: []
      }
    end

    def handle_new_turn(state, event)
      state[:turn]            = event.data.fetch(:turn)
      state[:started_at]      = event.metadata.fetch(:timestamp)
      state[:done_player_ids] = []
      state
    end

    def handle_player_ended_turn(state, event)
      player_id = state[:registered_slots][event.data.fetch(:slot)]
      state[:done_player_ids] << player_id
      state[:done_player_ids].uniq!
      state
    end

    def handle_player_end_turn_cancelled(state, event)
      player_id = state[:registered_slots][event.data.fetch(:slot)]
      state[:done_player_ids].delete(player_id)
      state
    end

    def handle_player_registered(state, event)
      state[:registered_slots][event.data.fetch(:slot_id)] =
        event.data.fetch(:player_id)
      state
    end
  end
end
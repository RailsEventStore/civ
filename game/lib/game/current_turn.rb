require "rails_event_store"

module Game
  class CurrentTurn
    Result = Struct.new(:turn, :unfinished_player_ids, :ends_at)
    private_constant :Result

    def initialize(event_store)
      @event_store = event_store
    end

    def call(stream_name)
      state =
        RailsEventStore::Projection
          .from_stream(stream_name)
          .init(method(:initial_state))
          .when(GameHosted, method(:handle_game_hosted))
          .when(PlayerRegistered, method(:handle_player_registered))
          .when(PlayerUnregistered, method(:handle_player_unregistered))
          .when(NewTurnStarted, method(:handle_new_turn))
          .when(PlayerEndedTurn, method(:handle_player_ended_turn))
          .when(PlayerEndTurnCancelled, method(:handle_player_end_turn_cancelled))
          .when(PlayerConnected, method(:handle_player_end_turn_cancelled))
          .run(@event_store, count: 10_000)
      Result.new(state[:turn], state[:unfinished_player_ids], state[:ends_at])
    end

    private

    def initial_state
      { registered_slots: {}, turn_timer: 0, turn: 0, ends_at: nil, unfinished_player_ids: [] }
    end

    def handle_new_turn(state, event)
      started_at = event.metadata.fetch(:timestamp)
      state[:turn] = event.data.fetch(:turn)
      state[:ends_at] = started_at + state[:turn_timer]
      state[:unfinished_player_ids] = state[:registered_slots].values
      state
    end

    def handle_player_ended_turn(state, event)
      player_id = state[:registered_slots][event.data.fetch(:slot)]
      state[:unfinished_player_ids].delete(player_id)

      state
    end

    def handle_player_end_turn_cancelled(state, event)
      player_id = state[:registered_slots][event.data.fetch(:slot)]
      state[:unfinished_player_ids] << player_id
      state[:unfinished_player_ids].uniq!
      state
    end

    def handle_player_registered(state, event)
      state[:registered_slots][event.data.fetch(:slot_id)] = event.data.fetch(:player_id)
      state
    end

    def handle_player_unregistered(state, event)
      removed_player_id = state[:registered_slots].delete(event.data.fetch(:slot_id))
      state[:unfinished_player_ids].delete(removed_player_id)
      state
    end

    def handle_game_hosted(state, event)
      state[:turn_timer] = event.data.fetch(:turn_timer)
      state
    end
  end
end

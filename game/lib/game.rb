require 'domain_event'
require 'rails_event_store'

module Game
  PlayerConnected        = Class.new(DomainEvent)
  PlayerDisconnected     = Class.new(DomainEvent)
  PlayerEndedTurn        = Class.new(DomainEvent)
  PlayerEndTurnCancelled = Class.new(DomainEvent)
  NewTurnStarted         = Class.new(DomainEvent)

  class CurrentTurn
    State = Struct.new(:turn, :done)
    private_constant :State

    def initialize(event_store)
      @event_store = event_store
      @projection  =
        RailsEventStore::Projection
         .from_all_streams
         .init(->{ State.new(0, []) })
         .when(NewTurnStarted,  method(:handle_new_turn))
         .when(PlayerEndedTurn, method(:handle_player_ended_turn))
         .when(PlayerEndTurnCancelled, method(:handle_player_end_turn_cancelled))
    end

    def call
      @projection.run(@event_store)
    end

    private

    def handle_new_turn(state, event)
      state.turn = event.data.fetch(:turn)
      state.done = []
      state
    end

    def handle_player_ended_turn(state, event)
      state.done << event.data.fetch(:slot)
      state.done.uniq!
      state
    end

    def handle_player_end_turn_cancelled(state, event)
      state.done.delete(event.data.fetch(:slot))
      state
    end
  end
end



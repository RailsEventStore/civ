require_relative 'spec_helper'

module Game
  RSpec.describe CurrentTurn do
    def event_store
      @event_store ||= RailsEventStore::Client.new(repository: RailsEventStore::InMemoryRepository.new)
    end

    def given(*domain_events)
      domain_events.each do |domain_event|
        event_store.append_to_stream(domain_event)
      end
    end

    specify do
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to       eq(0)
      expect(current_turn.done).to       eq([])
      expect(current_turn.started_at).to eq(nil)
    end

    specify do
      given(
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.done).to match_array([2, 3])
    end

    specify do
      given(
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
        PlayerEndTurnCancelled.new(data: { slot: 1 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.done).to match_array([2, 3])
    end

    specify do
      given(
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
        PlayerEndTurnCancelled.new(data: { slot: 1 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.done).to match_array([1, 2, 3])
    end

    specify do
      given(
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
        PlayerEndTurnCancelled.new(data: { slot: 1 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
        NewTurnStarted.new(data: { turn: 2 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(2)
      expect(current_turn.done).to eq([])
    end

    specify 'multiple turn ends' do
      given(
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 0 }),
        PlayerEndedTurn.new(data: { slot: 0 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.done).to eq([0])
    end


    specify do
      given(
        NewTurnStarted.new(
          data: {
            turn: 1
          },
          metadata: {
            timestamp: Time.at(0).utc
          }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.started_at).to eq(Time.at(0).utc)
    end
  end
end

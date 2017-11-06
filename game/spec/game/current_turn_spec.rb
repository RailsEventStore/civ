require_relative '../spec_helper'

module Game
  RSpec.describe CurrentTurn do
    include InMemoryEventStore

    def given(*domain_events)
      domain_events.each do |domain_event|
        event_store.append_to_stream(domain_event)
      end
    end

    def player_1
      '4e7b58e1-ccb9-4159-b891-48e954d1faae'
    end

    def player_2
      '95692a5a-04c4-4467-b1dc-76b095a76c4b'
    end

    def player_3
      '91488a8d-0e55-43e8-a95a-84ea0122cd0f'
    end

    specify do
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to                  eq(0)
      expect(current_turn.unfinished_player_ids).to eq([])
      expect(current_turn.ends_at).to               eq(nil)
    end

    specify do
      given(
        GameHosted.new(data: { turn_timer: 24.hours }),
        PlayerRegistered.new(data: { slot_id: 1, player_id: player_1 }),
        PlayerRegistered.new(data: { slot_id: 2, player_id: player_2 }),
        PlayerRegistered.new(data: { slot_id: 3, player_id: player_3 }),
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to                  eq(1)
      expect(current_turn.unfinished_player_ids).to match_array([player_1])
    end

    specify do
      given(
        GameHosted.new(data: { turn_timer: 24.hours }),
        PlayerRegistered.new(data: { slot_id: 1, player_id: player_1 }),
        PlayerRegistered.new(data: { slot_id: 2, player_id: player_2 }),
        PlayerRegistered.new(data: { slot_id: 3, player_id: player_3 }),
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
        PlayerEndTurnCancelled.new(data: { slot: 1 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.unfinished_player_ids).to match_array([player_1])
    end

    specify do
      given(
        GameHosted.new(data: { turn_timer: 24.hours }),
        PlayerRegistered.new(data: { slot_id: 1, player_id: player_1 }),
        PlayerRegistered.new(data: { slot_id: 2, player_id: player_2 }),
        PlayerRegistered.new(data: { slot_id: 3, player_id: player_3 }),
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 3 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
        PlayerEndTurnCancelled.new(data: { slot: 1 }),
        PlayerEndedTurn.new(data: { slot: 1 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.unfinished_player_ids).to match_array([])
    end

    specify do
      given(
        GameHosted.new(data: { turn_timer: 24.hours }),
        PlayerRegistered.new(data: { slot_id: 1, player_id: player_1 }),
        PlayerRegistered.new(data: { slot_id: 2, player_id: player_2 }),
        PlayerRegistered.new(data: { slot_id: 3, player_id: player_3 }),
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
      expect(current_turn.unfinished_player_ids).to eq([player_1, player_2, player_3])
    end

    specify 'multiple turn ends' do
      given(
        GameHosted.new(data: { turn_timer: 24.hours }),
        PlayerRegistered.new(data: { slot_id: 1, player_id: player_1 }),
        PlayerRegistered.new(data: { slot_id: 2, player_id: player_2 }),
        PlayerRegistered.new(data: { slot_id: 3, player_id: player_3 }),
        NewTurnStarted.new(data: { turn: 1 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
        PlayerEndedTurn.new(data: { slot: 2 }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.turn).to eq(1)
      expect(current_turn.unfinished_player_ids).to eq([player_1, player_3])
    end

    specify do
      given(
        GameHosted.new(data: { turn_timer: 24.hours }),
        NewTurnStarted.new(
          data: {
            turn: 1
          },
          metadata: {
            timestamp: Time.at(0).utc
          }),
      )
      current_turn = CurrentTurn.new(event_store).call

      expect(current_turn.ends_at).to eq(Time.at(24.hours).utc)
    end
  end
end

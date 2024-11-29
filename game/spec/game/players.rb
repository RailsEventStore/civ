require_relative "../spec_helper"

module Game
  RSpec.describe Player do
    include InMemoryEventStore

    def given(*domain_events)
      domain_events.each { |domain_event| event_store.append(domain_event, stream_name: game_id) }
    end

    def game_id
      "2d3e49d1-ff3f-4326-9e30-73463f349a84"
    end

    def player_1
      "4e7b58e1-ccb9-4159-b891-48e954d1faae"
    end

    def player_2
      "95692a5a-04c4-4467-b1dc-76b095a76c4b"
    end

    def player_3
      "91488a8d-0e55-43e8-a95a-84ea0122cd0f"
    end

    specify do
      player_ids = PlayerIds.new(event_store).call(game_id)

      expect(current_turn.player_ids).to eq([])
    end

    specify("player registered add to players list") do
      given(
        PlayerRegistered.new(data: {slot_id: 1, player_id: player_1}),
        PlayerRegistered.new(data: {slot_id: 2, player_id: player_2}),
        PlayerRegistered.new(data: {slot_id: 3, player_id: player_3})
      )
      player_ids = Players.new(event_store).call(game_id)

      expect(player_ids.player_ids).to match_array([player_1, player_2, player_3])
    end

    specify do
      given(
        GameHosted.new(data: {turn_timer: 24.hours.to_i}),
        NewTurnStarted.new(data: {turn: 1}, metadata: {timestamp: Time.at(0).utc})
      )
      current_turn = CurrentTurn.new(event_store).call(game_id)

      expect(current_turn.ends_at).to eq(Time.at(24.hours).utc)
    end

    specify("player unregistered doesn't remove from players") do
      given(
        PlayerRegistered.new(data: {slot_id: 1, player_id: player_1}),
        PlayerRegistered.new(data: {slot_id: 2, player_id: player_2}),
        PlayerRegistered.new(data: {slot_id: 3, player_id: player_3}),
        PlayerUnregistered.new(data: {slot_id: 3, player_id: player_3})
      )
      players = Players.new(event_store).call(game_id)

      expect(players.player_ids).to eq([player_1, player_2, player_3])
    end
  end
end

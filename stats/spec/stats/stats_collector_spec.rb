require_relative "../spec_helper"

module Stats
  RSpec.describe StatsCollector do
    include InMemoryEventStore

    def game_id
      "2d3e49d1-ff3f-4326-9e30-73463f349a84"
    end

    def player_1
      "12692a52-2424-1245-ba4c-22f095124cf4"
    end

    def player_2
      "95692a5a-04c4-4467-b1dc-76b095a76c4b"
    end

    def player_3
      "91488a8d-0e55-43e8-a95a-84ea0122cd0f"
    end

    def given(*domain_events)
      domain_events.each { |domain_event| event_store.publish(domain_event, stream_name: "Game$#{game_id}") }
    end

    specify("increment turns taken for players & turns last for the last one") do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours.to_i, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerDisconnected.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerDisconnected.new(data: {slot: 3, game_id: game_id})
      )

      expect(ReadModel::PlayerStat.find_by(player_id: player_1, game_id: "all").turns_taken).to eq(1)
      expect(ReadModel::PlayerStat.find_by(player_id: player_2, game_id: "all").turns_taken).to eq(1)
      expect(ReadModel::PlayerStat.find_by(player_id: player_3, game_id: "all").turns_taken).to eq(1)

      expect(ReadModel::PlayerStat.find_by(player_id: player_1, game_id: game_id).turns_taken).to eq(1)
      expect(ReadModel::PlayerStat.find_by(player_id: player_2, game_id: game_id).turns_taken).to eq(1)
      expect(ReadModel::PlayerStat.find_by(player_id: player_3, game_id: game_id).turns_taken).to eq(1)

      expect(ReadModel::PlayerStat.find_by(player_id: player_1, game_id: "all").turns_last).to eq(1)
      expect(ReadModel::PlayerStat.find_by(player_id: player_2, game_id: "all").turns_last).to eq(0)
      expect(ReadModel::PlayerStat.find_by(player_id: player_3, game_id: "all").turns_last).to eq(0)

      expect(ReadModel::PlayerStat.find_by(player_id: player_1, game_id: game_id).turns_last).to eq(1)
      expect(ReadModel::PlayerStat.find_by(player_id: player_2, game_id: game_id).turns_last).to eq(0)
      expect(ReadModel::PlayerStat.find_by(player_id: player_3, game_id: game_id).turns_last).to eq(0)
    end
  end
end

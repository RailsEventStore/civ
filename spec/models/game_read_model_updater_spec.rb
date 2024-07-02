require_relative "../spec_helper"
require "rails_helper"

module ReadModel
  RSpec.describe GameReadModelUpdater do
    def event_store
      Rails.configuration.event_store
    end

    def given(*domain_events)
      domain_events.each { |domain_event|
        event_store.publish(domain_event, stream_name: "Game$#{domain_event.data.fetch(:game_id)}")
      }
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
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(0)
      expect(read_model.unfinished_player_ids).to eq([])
      expect(read_model.player_ids).to eq([])
      expect(read_model.ends_at).to eq(nil)
      expect(read_model.registered_slots).to eq({})
    end

    specify do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(1)
      expect(read_model.unfinished_player_ids).to match_array([player_1])
      expect(read_model.registered_slots).to(
        eq(
          {
            1 => "4e7b58e1-ccb9-4159-b891-48e954d1faae",
            2 => "95692a5a-04c4-4467-b1dc-76b095a76c4b",
            3 => "91488a8d-0e55-43e8-a95a-84ea0122cd0f"
          }
        )
      )
    end

    specify do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 1, game_id: game_id}),
        Game::PlayerEndTurnCancelled.new(data: {slot: 1, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)
      expect(read_model.turn).to eq(1)
      expect(read_model.unfinished_player_ids).to match_array([player_1])
    end

    specify do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 1, game_id: game_id}),
        Game::PlayerEndTurnCancelled.new(data: {slot: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 1, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(1)
      expect(read_model.unfinished_player_ids).to match_array([])
    end

    specify do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 1, game_id: game_id}),
        Game::PlayerEndTurnCancelled.new(data: {slot: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 1, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 2, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(2)
      expect(read_model.unfinished_player_ids).to eq([player_1, player_2, player_3])
    end

    specify("multiple turn ends") do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(1)
      expect(read_model.unfinished_player_ids).to eq([player_1, player_3])
    end

    specify("player connected sets turn unfinished") do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 1, game_id: game_id}),
        Game::PlayerConnected.new(data: {slot: 1, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(1)
      expect(read_model.unfinished_player_ids).to eq([player_1])
      expect(read_model.player_ids).to eq([player_1, player_2, player_3])
    end

    specify do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}, metadata: {timestamp: Time.at(0).utc})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.ends_at).to eq(Time.at(24.hours).utc)
    end

    specify("player unregistered") do
      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id}),
        Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerUnregistered.new(data: {slot_id: 3, player_id: player_3, game_id: game_id})
      )
      read_model = ReadModel::GameReadModel.find(game_id)

      expect(read_model.turn).to eq(1)
      expect(read_model.unfinished_player_ids).to eq([player_1])
      expect(read_model.player_ids).to eq([player_1, player_2, player_3])
      expect(read_model.registered_slots).to(
        eq({1 => "4e7b58e1-ccb9-4159-b891-48e954d1faae", 2 => "95692a5a-04c4-4467-b1dc-76b095a76c4b"})
      )
    end
  end
end

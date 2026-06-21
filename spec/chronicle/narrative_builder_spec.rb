require "rails_helper"

module Chronicle
  RSpec.describe NarrativeBuilder do
    let(:game_id) { "2d3e49d1-ff3f-4326-9e30-73463f349a84" }
    subject(:builder) { NarrativeBuilder.new }

    def entries
      GameChronicleEntry.where(game_id: game_id)
    end

    specify "NewTurnStarted records turn beginning" do
      builder.call(Game::NewTurnStarted.new(data: {turn: 5, game_id: game_id}))

      expect(entries.sole.text).to eq("Turn 5 has begun.")
    end

    specify "CityFounded records city founding with player name" do
      player = Player.create!(steam_name: "Alice", slack_name: "alice")
      ReadModel::GameReadModel.create!(id: game_id, name: "Test", registered_slots: {0 => player.id})

      builder.call(Game::CityFounded.new(data: {game_id: game_id, slot: 0}))

      expect(entries.sole.text).to eq("alice has founded a new city.")
    end

    specify "CityFounded with unknown player" do
      ReadModel::GameReadModel.create!(id: game_id, name: "Test", registered_slots: {})

      builder.call(Game::CityFounded.new(data: {game_id: game_id, slot: 0}))

      expect(entries.sole.text).to eq("Unknown player has founded a new city.")
    end

    specify "CityConquered with annexed action includes player name" do
      player = Player.create!(steam_name: "Bob", slack_name: "bob")
      ReadModel::GameReadModel.create!(id: game_id, name: "Test", registered_slots: {1 => player.id})

      builder.call(Game::CityConquered.new(data: {game_id: game_id, slot: 1, action: "annexed"}))

      expect(entries.sole.text).to eq("bob has annexed a city.")
    end

    specify "CityConquered with puppeted action includes player name" do
      player = Player.create!(steam_name: "Bob", slack_name: "bob")
      ReadModel::GameReadModel.create!(id: game_id, name: "Test", registered_slots: {1 => player.id})

      builder.call(Game::CityConquered.new(data: {game_id: game_id, slot: 1, action: "puppeted"}))

      expect(entries.sole.text).to eq("bob has puppeted a city.")
    end

    specify "CityConquered with razing_started action includes player name" do
      player = Player.create!(steam_name: "Bob", slack_name: "bob")
      ReadModel::GameReadModel.create!(id: game_id, name: "Test", registered_slots: {1 => player.id})

      builder.call(Game::CityConquered.new(data: {game_id: game_id, slot: 1, action: "razing_started"}))

      expect(entries.sole.text).to eq("bob has started razing a city.")
    end

    specify "CityConquered with unknown player" do
      ReadModel::GameReadModel.create!(id: game_id, name: "Test", registered_slots: {})

      builder.call(Game::CityConquered.new(data: {game_id: game_id, slot: 1, action: "annexed"}))

      expect(entries.sole.text).to eq("Unknown player has annexed a city.")
    end

    specify "WarStatusChanged records war status change" do
      builder.call(Game::WarStatusChanged.new(data: {game_id: game_id}))

      expect(entries.sole.text).to eq("War status has changed.")
    end

    specify "event_type is stored as class name" do
      builder.call(Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id}))

      expect(entries.sole.event_type).to eq("Game::NewTurnStarted")
    end

    specify "occurred_at is taken from event metadata timestamp" do
      timestamp = Time.at(1_000_000).utc
      builder.call(Game::NewTurnStarted.new(
        data: {turn: 1, game_id: game_id},
        metadata: {timestamp: timestamp}
      ))

      expect(entries.sole.occurred_at).to eq(timestamp)
    end

    specify "unhandled events create no entry" do
      builder.call(Game::PlayerConnected.new(data: {slot: 1, game_id: game_id}))

      expect(entries).to be_empty
    end
  end
end

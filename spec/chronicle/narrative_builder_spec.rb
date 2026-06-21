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

    specify "CityFounded records city founding" do
      builder.call(Game::CityFounded.new(data: {game_id: game_id}))

      expect(entries.sole.text).to eq("A new city has been founded.")
    end

    specify "CityConquered with annexed action" do
      builder.call(Game::CityConquered.new(data: {game_id: game_id, action: "annexed"}))
      expect(entries.sole.text).to eq("A city has been annexed.")
    end

    specify "CityConquered with puppeted action" do
      builder.call(Game::CityConquered.new(data: {game_id: game_id, action: "puppeted"}))
      expect(entries.sole.text).to eq("A city has been puppeted.")
    end

    specify "CityConquered with razing_started action" do
      builder.call(Game::CityConquered.new(data: {game_id: game_id, action: "razing_started"}))
      expect(entries.sole.text).to eq("A city is being razed.")
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

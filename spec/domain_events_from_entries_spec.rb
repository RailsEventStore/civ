require "rails_helper"

RSpec.describe "glue entries with domain events" do
  def event_store
    Rails.configuration.event_store
  end

  specify("NewTurnStarted") do
    PitbossEntry.create(timestamp: 0, value: 61, entry_type: "NewTurnStarted", game_name: "dummy")
    expect(event_store).to(have_published(an_event(Game::NewTurnStarted).with_data(turn: 61, game_id: "dummy")))
  end

  specify("PlayerEndedTurn") do
    PitbossEntry.create(timestamp: 0, value: 4, entry_type: "PlayerEndedTurn", game_name: "dummy")

    expect(event_store).to(have_published(an_event(Game::PlayerEndedTurn).with_data(slot: 4, game_id: "dummy")))
  end

  specify("PlayerEndTurnCancelled") do
    PitbossEntry.create(timestamp: 0, value: 4, entry_type: "PlayerEndTurnCancelled", game_name: "dummy")

    expect(event_store).to(have_published(an_event(Game::PlayerEndTurnCancelled).with_data(slot: 4, game_id: "dummy")))
  end

  specify("PlayerConnected") do
    PitbossEntry.create(timestamp: 0, value: 4, entry_type: "PlayerConnected", game_name: "dummy")

    expect(event_store).to(have_published(an_event(Game::PlayerConnected).with_data(slot: 4, game_id: "dummy")))
  end

  specify("PlayerDisconnected") do
    PitbossEntry.create(timestamp: 0, value: 4, entry_type: "PlayerDisconnected", game_name: "dummy")

    expect(event_store).to(have_published(an_event(Game::PlayerDisconnected).with_data(slot: 4, game_id: "dummy")))
  end

  specify do
    PitbossEntry.create(timestamp: 0, value: 4, entry_type: "PlayerDisconnected", game_name: "dummy")
    PitbossEntry.last.update(entry_type: "PlayerConnected")

    expect(event_store).not_to(have_published(an_event(Game::PlayerConnected)))
  end

  specify do
    PitbossEntry.new(timestamp: 0, value: 4, entry_type: "PlayerDisconnected", game_name: "dummy")

    expect(event_store).not_to(have_published(an_event(Game::PlayerDisconnected)))
  end

  specify("TimerReset") do
    PitbossEntry.create(timestamp: 0, value: 5, entry_type: "TimerReset", game_name: "dummy")

    expect(event_store).to(have_published(an_event(Game::TimerReset).with_data(slot: 5, game_id: "dummy")))
  end
end

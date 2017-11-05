require "rails_helper"

RSpec.describe "glue entries with domain events" do
  def event_store
    Rails.configuration.event_store
  end

  specify "NewTurnStarted" do
    PitbossEntry.create(
      timestamp: 0,
      value: 61,
      entry_type: "NewTurnStarted",
      game_name: "dummy"
    )

    expect(event_store).to have_published(an_event(Game::NewTurnStarted))
  end
end
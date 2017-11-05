class PitbossEntry < ApplicationRecord
  after_create_commit do
    event_store = Rails.configuration.event_store

    case entry_type
    when "NewTurnStarted"
      event_store.publish_event(Game::NewTurnStarted.new)
    when "PlayerEndedTurn"
      event_store.publish_event(Game::PlayerEndedTurn.new)
    when "PlayerEndTurnCancelled"
      event_store.publish_event(Game::PlayerEndTurnCancelled.new)
    when "PlayerConnected"
      event_store.publish_event(Game::PlayerConnected.new)
    when "PlayerDisconnected"
      event_store.publish_event(Game::PlayerDisconnected.new)
    end
  end
end

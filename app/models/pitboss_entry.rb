class PitbossEntry < ApplicationRecord
  after_create_commit do |record|
    record.entry_to_domain_event
  end

  def entry_to_domain_event
    event_store = Rails.configuration.event_store

    case entry_type
    when "NewTurnStarted"
      event_store.publish_event(Game::NewTurnStarted.new(data: {
        turn: value.to_i
      }))
    when "PlayerEndedTurn"
      event_store.publish_event(Game::PlayerEndedTurn.new(data: {
        slot: value.to_i
      }))
    when "PlayerEndTurnCancelled"
      event_store.publish_event(Game::PlayerEndTurnCancelled.new(data: {
        slot: value.to_i
      }))
    when "PlayerConnected"
      event_store.publish_event(Game::PlayerConnected.new(data: {
        slot: value.to_i
      }))
    when "PlayerDisconnected"
      event_store.publish_event(Game::PlayerDisconnected.new(data: {
        slot: value.to_i
      }))
    end
  end
end

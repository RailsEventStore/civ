events_to_delete = %w[
  Game::PlayerConnected
  Game::PlayerDisconnected
  Game::PlayerEndedTurn
  Game::PlayerEndTurnCancelled
  Game::NewTurnStarted
]

RailsEventStoreActiveRecord::Event
  .where("created_at < ?", Time.current - 2.days)
  .where(event_type: events_to_delete)
  .each do |event|
    RailsEventStoreActiveRecord::EventInStream.where(event_id: event.id).delete_all
    event.delete
  end

PitbossEntry.delete_all

class PitbossEntry < ApplicationRecord
  after_create_commit { |record| record.entry_to_domain_event }

  def entry_to_domain_event
    event_store = Rails.configuration.event_store

    case entry_type
    when "NewTurnStarted"
      event_store.publish(
        Game::NewTurnStarted.new(data: { turn: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "PlayerEndedTurn"
      event_store.publish(
        Game::PlayerEndedTurn.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "PlayerEndTurnCancelled"
      event_store.publish(
        Game::PlayerEndTurnCancelled.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "PlayerConnected"
      event_store.publish(
        Game::PlayerConnected.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "PlayerDisconnected"
      event_store.publish(
        Game::PlayerDisconnected.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    end
  end
end

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
    when "TimerReset"
      event_store.publish(
        Game::TimerReset.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "CityFounded"
      event_store.publish(
        Game::CityFounded.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "WarStatusChanged"
      event_store.publish(
        Game::WarStatusChanged.new(data: { slot: value.to_i, game_id: game_name }),
        stream_name: "Game$#{game_name}"
      )
    when "CityConquered"
      event_store.publish(
        Game::CityConquered.new(data: { slot: value.to_i, game_id: game_name, action: "conquered" }),
        stream_name: "Game$#{game_name}"
      )
    when "CityPuppeted"
      event_store.publish(
        Game::CityConquered.new(data: { slot: value.to_i, game_id: game_name, action: "puppeted" }),
        stream_name: "Game$#{game_name}"
      )
    when "CityAnnexed"
      event_store.publish(
        Game::CityConquered.new(data: { slot: value.to_i, game_id: game_name, action: "annexed" }),
        stream_name: "Game$#{game_name}"
      )
    when "CityRazingStarted"
      event_store.publish(
        Game::CityConquered.new(data: { slot: value.to_i, game_id: game_name, action: "razing_started" }),
        stream_name: "Game$#{game_name}"
      )
    end
  end
end

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new.tap do |client|
    client.subscribe(->(event) { ReadModel::Game.handle_game_hosted(event) }, [Game::GameHosted])
  end
end

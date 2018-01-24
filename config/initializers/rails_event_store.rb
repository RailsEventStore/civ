Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new.tap do |client|
    client.subscribe(->(event) { ReadModel::GameReadModel.handle_game_hosted(event) }, [Game::GameHosted])
    client.subscribe(->(event) { Notifications::SlackNotifier.new(logger: Rails.logger, event_store: Rails.configuration.event_store).call(event) }, [Game::NewTurnStarted, Game::PlayerDisconnected])
  end
end

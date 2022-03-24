Rails.configuration.to_prepare do
  Rails.configuration.event_store =
    RailsEventStore::Client.new.tap do |client|
      client.subscribe(->(event) { ReadModel::GameReadModel.handle_game_hosted(event) }, to: [Game::GameHosted])
      client.subscribe(
        ->(event) do
          Notifications::SlackNotifier
            .new(logger: Rails.logger, event_store: Rails.configuration.event_store)
            .call(event)
        end,
        to: [Game::NewTurnStarted, Game::PlayerDisconnected]
      )
      client.subscribe(
        ->(event) do
          Stats::StatsCollector.new(logger: Rails.logger, event_store: Rails.configuration.event_store).call(event)
        end,
        to: [Game::NewTurnStarted, Game::PlayerDisconnected]
      )
    end
end

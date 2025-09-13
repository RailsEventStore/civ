Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new.tap do |client|
    if Rails.env.test?
      # In test environment, only add essential subscribers for compatibility
      client.subscribe(-> (event) { ReadModel::GameReadModel.handle_game_hosted(event) }, to: [Game::GameHosted])
      client.subscribe(
        -> (event) do
          ReadModel::GameReadModelUpdater.new(logger: Rails.logger).call(event)
        end,
        to: [
          Game::GameHosted,
          Game::PlayerRegistered,
          Game::PlayerUnregistered,
          Game::NewTurnStarted,
          Game::PlayerEndedTurn,
          Game::PlayerEndTurnCancelled,
          Game::PlayerConnected
        ]
      )
      next
    end
    client.subscribe(-> (event) { ReadModel::GameReadModel.handle_game_hosted(event) }, to: [Game::GameHosted])
    client.subscribe(
      -> (event) do
        Notifications::SlackNotifier
          .new(logger: Rails.logger, event_store: Rails.configuration.event_store)
          .call(event)
      end,
      to: [Game::NewTurnStarted, Game::PlayerDisconnected, Game::TimerReset]
    )
    client.subscribe(
      -> (event) do
        Stats::StatsCollector.new(logger: Rails.logger, event_store: Rails.configuration.event_store).call(event)
      end,
      to: [Game::NewTurnStarted, Game::PlayerDisconnected]
    )
    client.subscribe(
      -> (event) do
        ReadModel::GameReadModelUpdater.new(logger: Rails.logger).call(
          event
        )
      end,
      to: [
        Game::PlayerRegistered,
        Game::PlayerUnregistered,
        Game::NewTurnStarted,
        Game::PlayerEndedTurn,
        Game::PlayerEndTurnCancelled,
        Game::PlayerConnected
      ]
    )
  end
end

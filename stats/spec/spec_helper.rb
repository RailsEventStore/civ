ENV["RAILS_ENV"] = "test"

$LOAD_PATH.push(File.expand_path("../../../spec", __FILE__))
$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))
$LOAD_PATH.push(File.expand_path("../../../game/lib", __FILE__))

require "stats"
require "game"
require "ruby_event_store/rspec"
require "rails_helper"

module InMemoryEventStore
  def event_store
    @event_store ||= RailsEventStore::Client
      .new(repository: RailsEventStore::InMemoryRepository.new)
      .tap do |client|
        client.subscribe(
          -> (event) { Stats::StatsCollector.new(event_store: client).call(event) },
          to: [Game::NewTurnStarted, Game::PlayerDisconnected]
        )
        client.subscribe(
          -> (event) { Notifications::SlackNotifier.new(logger: Rails.logger, event_store: client).call(event) },
          to: [Game::NewTurnStarted, Game::PlayerDisconnected, Game::TimerReset]
        )
        client.subscribe(
          ->(event) { ReadModel::GameReadModelUpdater.new(logger: Rails.logger).call(event) },
          to: [Game::PlayerRegistered]
        )
      end
  end
end

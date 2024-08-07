ENV["RAILS_ENV"] = "test"

$LOAD_PATH.push(File.expand_path("../../../spec", __FILE__))
$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require "game"
require "ruby_event_store/rspec"

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
          to: [Game::NewTurnStarted, Game::PlayerDisconnected]
        )
      end
  end
end

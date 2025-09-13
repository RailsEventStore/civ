ENV["RAILS_ENV"] = "test"

$LOAD_PATH.push File.expand_path("../../../spec", __FILE__)
$LOAD_PATH.push File.expand_path("../../lib", __FILE__)
$LOAD_PATH.push File.expand_path("../../../game/lib", __FILE__)

require "notifications"
require "game"
require "ruby_event_store/rspec"
require "rails_helper"

module InMemoryEventStore
  def event_store
    @event_store ||=
      RailsEventStore::Client
        .new(repository: RailsEventStore::InMemoryRepository.new)
        .tap do |client|
          puts "=== SUBSCRIBING TO InMemoryEventStore ==="
          client.subscribe(
            ->(event) {
              puts "SlackNotifier subscriber called for #{event.class}"
              Notifications::SlackNotifier.new(logger: Rails.logger, event_store: client).call(event)
            },
            to:  [Game::NewTurnStarted, Game::PlayerDisconnected, Game::TimerReset]
          )
          client.subscribe(
            ->(event) {
              puts "GameReadModelUpdater subscriber called for #{event.class}"
              ReadModel::GameReadModelUpdater.new(logger: Rails.logger).call(event)
            },
            to: [Game::PlayerRegistered]
          )
          puts "=== SUBSCRIPTIONS COMPLETE ==="
        end
  end
end
